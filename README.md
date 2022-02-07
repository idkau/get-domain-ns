# get-domain-ns

I needed a Name Server records of many domains. The script is for use on a cpanel server. It creates a list of domains, makes several DNS queries based on that list, and then sends the output in an email after sending the data to a CSV file. Its then processed by SES and lambda for use later on.
