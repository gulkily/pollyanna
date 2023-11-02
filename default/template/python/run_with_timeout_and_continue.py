import subprocess

def run_command_with_timeout(command, timeout):
  """Runs a command with a timeout.

  Args:
    command: The command to run.
    timeout: The timeout in seconds.

  Returns:
    The return code of the command.
  """

  child_process = subprocess.Popen(command, shell=True)
  child_process.wait(timeout)

  if child_process.returncode is None:
    # The command timed out.
    child_process.terminate()
    return -1
  else:
    return child_process.returncode

# Example usage:

command = "sleep 10"
timeout = 5

return_code = run_command_with_timeout(command, timeout)

if return_code == -1:
  print("The command timed out.")
else:
  print("The command returned successfully.")

# (c)GoogleBard
