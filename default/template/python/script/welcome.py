import time

def print_welcome_message(digits=5):
    message = f"Welcome to what I do on the computer all day, volume {get_partial_epoch_date(digits)}"
    print(message)

def get_partial_epoch_date(digits=5):
    current_epoch_time = str(int(time.time()))
    return current_epoch_time[:digits]

# Example usage:
print_welcome_message(digits=5)

