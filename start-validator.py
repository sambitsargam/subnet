#!/usr/bin/env python3

import os
import sys
import signal
import subprocess
import logging
from pathlib import Path
import time
from datetime import datetime

from git import Repo, GitCommandError
from apscheduler.schedulers.blocking import BlockingScheduler

############## Configuration ##############
BRANCH_NAME = "mainnet"
MAINNET_NETUID = 60

# How often we... (in minutes)
INTERVAL_UPDATE_CODE = 10
INTERVAL_PROCESS_ALIVE = 1

# Paths
WORKING_DIRECTORY = Path(".")   # Current directory
START_SCRIPT = WORKING_DIRECTORY / "scripts/start-validator-once.sh"
PID_FILE = WORKING_DIRECTORY / "validator.pid"

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
def is_process_alive() -> bool:
    """Check if the PID in PID_FILE corresponds to a running process."""
    if not PID_FILE.is_file():
        return False
    try:
        pid = int(PID_FILE.read_text().strip())
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
    if is_process_alive():
        return
    
    logging.info("Starting validator...")
    
    # Use bash -c to properly execute the shell script with environment
    cmd = f"bash -c '{START_SCRIPT} --netuid {MAINNET_NETUID}'"

    process = subprocess.Popen(
        cmd,
        cwd=WORKING_DIRECTORY,
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
                if time.time() - start_time < 10:   
                    logging.info("Calling soft quit (SIGTERM)...")
                    os.killpg(os.getpgid(pid), signal.SIGTERM)
                else:
                    logging.info("Calling hard quit (-9, SIGKILL)...")
                    os.killpg(os.getpgid(pid), signal.SIGKILL)

                time.sleep(1)
         
                # Check if process exists
                os.kill(pid, 0)
            except ProcessLookupError:
                killed = True
                break
            except OSError:
                killed = True
                break
            
            time.sleep(1)
        
        if not killed:
            logging.error(f"😒😒😒😒😒😒\n" +
                        f"\tFailed to exit validator pid {pid}, after 30 seconds.\n" +
                        f"\tCheck if still running by calling `kill -0 {pid}` -- if you get 'No such process' then you're good.\n" +
                        f"\tOtherwise, you should manually quit by calling `kill -9 {pid}`.\n" +
                        f"\tIf that doesn't work, try restarting your machine.")
            
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

    repo = Repo(str(WORKING_DIRECTORY))
    git_cmd = repo.git

    # 1. Fetch
    try:
        repo.remotes.origin.fetch()
    except GitCommandError as e:
        logging.error(f"Failed to fetch changes: {e}")
        return

    # Check for detached HEAD state and reset
    if repo.head.is_detached:
        logging.warning("HEAD is detached. Resetting to branch head...")
        try:
            git_cmd.reset('--hard', f'origin/{BRANCH_NAME}')
            git_cmd.checkout(BRANCH_NAME)
        except GitCommandError as e:
            logging.error(f"Failed to reset and checkout branch '{BRANCH_NAME}': {e}")
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
        # Unless local branch is g/validator-auto-update, switch to BRANCH_NAME
        if repo.active_branch.name != "g/validator-auto-update":
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
        try:
            git_cmd.checkout(local_commit)
        except GitCommandError as e:
            logging.error(f"Failed to checkout previous commit: {e}")

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
    if not is_process_alive():
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

    # Just to be safe
    stop_validator()

    try:
        check_for_updates()
    except Exception as e:
        logging.error(f"Failed initial updates check: {e}")

    try:
        scheduler = BlockingScheduler()

        # 1) Check for Git updates
        scheduler.add_job(
            check_for_updates,
            'interval',
            minutes=INTERVAL_UPDATE_CODE,
            id='check_for_updates_job'
        )

        # 2) Ensure the validator is alive
        scheduler.add_job(
            ensure_validator_is_running,
            'interval',
            minutes=INTERVAL_PROCESS_ALIVE,
            next_run_time=datetime.now(), # Run immediately
            id='ensure_validator_running_job'
        )

        scheduler.start()
    except (KeyboardInterrupt, SystemExit):
        logging.info("Scheduler shutting down...")

if __name__ == "__main__":
    main()
