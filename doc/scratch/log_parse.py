import re

def parse_log_line(line):
    pattern = re.compile(r'(\d+\.\d+) \S+ (\w+): (.+)')
    match = pattern.match(line)
    
    if match:
        epoch_time = float(match.group(1))
        function_name = match.group(2)
        log_message = match.group(3)
        return epoch_time, function_name, log_message
    else:
        return None

def analyze_log(log_path, time_threshold_seconds):
    with open(log_path, 'r') as file:
        for line in file:
            parsed_data = parse_log_line(line)
            
            if parsed_data:
                epoch_time, function_name, _ = parsed_data
                
                # Perform your analysis based on time_threshold_seconds
                if epoch_time > time_threshold_seconds:
                    print(f"Function '{function_name}' took more than {time_threshold_seconds} seconds at epoch time {epoch_time}")

# Example usage with a decimal point in the seconds threshold value
log_file_path = './log/log.log'
time_threshold_seconds = 0.5  # Replace with your desired threshold in seconds
analyze_log(log_file_path, time_threshold_seconds)
