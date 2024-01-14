import subprocess
from collections import defaultdict
from datetime import datetime

# Define the path to your Git repository
repository_path = '/home/wsl/pollyanna'

# Execute Git command to get the commit history
git_command = ['git', '--git-dir=' + repository_path + '/.git', 'log', '--pretty=format:%ad', '--date=format:%Y-%m']

# Run the Git command and capture its output
commit_history = subprocess.check_output(git_command, cwd=repository_path, text=True)

# Create a dictionary to store the commit count for each year-month
commit_counts = defaultdict(int)

# Parse the commit history and count commits for each year-month
for line in commit_history.splitlines():
    date = line.strip()
    year_month = datetime.strptime(date, '%Y-%m').strftime('%Y-%m')
    commit_counts[year_month] += 1

# Output the results
for year_month, count in commit_counts.items():
    print(f'{year_month}, {count}')
