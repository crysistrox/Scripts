import sys

def decode(message_file):
    # Read the lines from the file
    with open(message_file, 'r') as file:
        lines = file.readlines()

    decoded_message = []

    # Extract the words corresponding to the pyramid numbers
    for line in lines:
        num, word = line.split()
        # Convert the number to an integer
        num = int(num)
        # Append the word to the decoded message list
        decoded_message.append(word)

    # Join the decoded words into a single string
    return ' '.join(decoded_message)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python decoder.py <message_file>")
        sys.exit(1)

    message_file = sys.argv[1]
    decoded_message = decode(message_file)
    print(decoded_message)
