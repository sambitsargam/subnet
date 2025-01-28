#!/usr/bin/env python3

import os
import sys
import signal
import subprocess
import logging
from pathlib import Path
import time

from git import Repo, GitCommandError
from apscheduler.schedulers.blocking import BlockingScheduler

##########################################
# Configuration
##########################################
REPO_PATH = Path(".")   # Current directory where the script is running
BRANCH_NAME = "mainnet"
START_SCRIPT = "./start-validator.sh"
PID_FILE = REPO_PATH / "validator.pid"

# How often we check for updates (in minutes)
CHECK_FOR_UPDATES_INTERVAL = 10

# How often we check the validator process is still running (in minutes)
CHECK_PROCESS_ALIVE_INTERVAL = 1

##########################################
# Logging
##########################################
# Set up logging so that it goes to the console (stdout)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    stream=sys.stdout
    # Note: no "filename=" means we're not logging to a file
)

# Suppress APScheduler info messages
logging.getLogger('apscheduler').setLevel(logging.WARNING)

##########################################
# Helper Functions
##########################################
def is_process_alive(pid_file: Path) -> bool:
    """Check if the PID in pid_file corresponds to a running process."""
    if not pid_file.is_file():
        return False
    try:
        pid = int(pid_file.read_text().strip())
    except ValueError:
        return False

    # kill(pid, 0) == "kill -0 <pid>" => check existence
    try:
        os.kill(pid, 0)
        return True  # No exception => process is alive
    except OSError:
        return False

def start_validator():
    """Start the validator. Output goes to the same screen as this script."""
    logging.info("Starting validator...")
    
    # Use bash -c to properly execute the shell script with environment
    cmd = f"bash -c '{START_SCRIPT}'"

    process = subprocess.Popen(
        cmd,
        cwd=REPO_PATH,
        shell=True,
        executable='/bin/bash',
        # Ensure output is properly forwarded
        stdout=sys.stdout,
        stderr=sys.stderr,
        # Required for shell=True
        text=True,
        bufsize=1,
        preexec_fn=os.setsid  # Create new process group
    )
    
    # Write PID to file
    if process.pid:
        PID_FILE.write_text(str(process.pid))

    # Ensure process is properly terminated
    def cleanup_process():
        try:
            process.terminate()
            process.wait(timeout=5)
        except Exception as e:
            logging.warning(f"Failed to terminate process: {e}")

    import atexit
    atexit.register(cleanup_process)

def stop_validator():
    """Stops the validator if it's running."""
    if not PID_FILE.is_file():
        return
    
    try:
        pid = int(PID_FILE.read_text().strip())
        logging.info(f"Stopping validator process group with PID={pid}")
        
        # Try to kill for up to 30 seconds
        start_time = time.time()
        killed = False
        
        while time.time() - start_time < 30:
            try:
                # First try SIGTERM
                os.killpg(os.getpgid(pid), signal.SIGTERM)
                time.sleep(1)
                
                # If still alive, use SIGKILL
                os.killpg(os.getpgid(pid), signal.SIGKILL)
                time.sleep(1)
                
                # Check if process exists
                os.kill(pid, 0)
                logging.info("Process still alive, retrying kill...")
            except ProcessLookupError:
                killed = True
                logging.info("Process successfully killed")
                break
            except OSError:
                killed = True
                break
            
            time.sleep(1)
        
        if not killed:
            logging.error(f"Failed to kill process {pid} after 30 seconds. Try manually killing with 'kill -9 {pid}' or 'pkill -9 -f start-validator.sh. If that doesn't work, try restarting your machine.")
            
    except (ValueError, ProcessLookupError):
        pass
    finally:
        # Clean up PID file
        PID_FILE.unlink(missing_ok=True)

def check_for_updates():
    """
    1. Fetch remote changes on BRANCH_NAME.
    2. Compare local vs. remote commits.
    3. If no difference, return early.
    4. If difference, check if repo is dirty; if so, stash. Pull. Then pop if stash was created.
    5. Stop validator & restart with new code
    """
    logging.info("Checking for updates...")

    repo = Repo(str(REPO_PATH))
    git_cmd = repo.git

    # 1. Fetch
    try:
        repo.remotes.origin.fetch()
    except GitCommandError as e:
        logging.error(f"Failed to fetch changes: {e}")
        return

    # 2. Compare local vs. remote commits
    try:
        local_commit = repo.head.commit.hexsha
        remote_commit = repo.remotes.origin.refs[BRANCH_NAME].commit.hexsha
    except (AttributeError, IndexError) as e:
        logging.error(f"Could not find branch '{BRANCH_NAME}' or commits: {e}")
        return

    # 3. If no difference, return early
    if local_commit == remote_commit:
        logging.info("✅ Code is up to date.")
        return
    
    logging.info("🔄 Pulling new code...")

    # 4. Check if we need to stash
    stash_created = False
    if repo.is_dirty(untracked_files=True):
        try:
            stash_result = git_cmd.stash('push', '-u', '-m', 'auto-update-stash')
            if "No local changes to save" not in stash_result:
                stash_created = True
                logging.info("🔖 Local changes stashed successfully.")
        except GitCommandError as e:
            logging.warning(f"🔖 Stash failed: {e}")

    # Switch branch (just to be sure), then pull
    try:
        git_cmd.checkout(BRANCH_NAME)
    except GitCommandError as e:
        message = f"❌ Failed to checkout branch '{BRANCH_NAME}': {e}.\n\n"
        message += "⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️\n"
        message += "Try manually updating by running 'git reset --hard HEAD && git clean -fd && git checkout {BRANCH_NAME} && git pull && python3 start-validator-autoupdate.py'.\n\n"
        message += "⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️\n"
        logging.error(message)
        if stash_created:
            git_cmd.stash('pop')
        return

    try:
        repo.remotes.origin.pull(BRANCH_NAME)
        logging.info("Pull successful.")
    except GitCommandError as e:
        logging.error(f"Failed to pull: {e}")
        # Roll back to old commit if needed
        logging.info("Reverting to previous commit...")
        git_cmd.checkout(local_commit)
        if stash_created:
            git_cmd.stash('pop')
        return

    # Pop stash if we created one
    if stash_created:
        try:
            git_cmd.stash('pop')
            logging.info("Stash popped successfully.")
        except GitCommandError as e:
            logging.warning(f"Stash pop conflict or issue: {e}")

    # 5. Stop validator & restart with new code
    stop_validator()
    start_validator()

def ensure_validator_is_running():
    """Checks if the validator is alive. If not, starts it."""
    if not is_process_alive(PID_FILE):
        logging.warning("Validator is not running. Starting it now...")
        start_validator()
    else:
        logging.info("Validator is still running.")

def setup_shutdown_handler():
    """Setup signal handlers to ensure proper shutdown."""
    def shutdown_handler(signum, frame):
        logging.info("Received shutdown signal. Stopping validator...")
        stop_validator()
        logging.info("Validator stopped. Exiting...")
        sys.exit(0)

    # Register the handler for termination signals
    signal.signal(signal.SIGTERM, shutdown_handler)
    signal.signal(signal.SIGINT, shutdown_handler)

##########################################
# Main: Setup the Scheduler
##########################################
def main():
    setup_shutdown_handler()

    scheduler = BlockingScheduler()

    # 1) Check for Git updates every 5 minutes
    scheduler.add_job(
        check_for_updates,
        'interval',
        minutes=CHECK_FOR_UPDATES_INTERVAL,
        id='check_for_updates_job'
    )

    # 2) Ensure the validator is alive every 1 minute
    scheduler.add_job(
        ensure_validator_is_running,
        'interval',
        minutes=CHECK_PROCESS_ALIVE_INTERVAL,
        id='ensure_validator_running_job'
    )

    logging.info("Starting APScheduler for auto-updates and validator checks...")

    stop_validator()

    logging.info("Running initial update check before starting validator...")
    check_for_updates()

    start_validator()

    try:
        scheduler.start()
    except (KeyboardInterrupt, SystemExit):
        logging.info("Scheduler shutting down...")

if __name__ == "__main__":
    main()
