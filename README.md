log4r-azure
===================

Ruby gem for Log4r that uses Windows Azure Table Storage as an Outputter.

## Table Storage
You must already have an Azure storage account created. Once you've nominated the account to use, log4r-azure will use a table called "logging" by default.

The Partition Key will be set to "Logging<Month><Year>", for example if we're logging for March 2014, you'd see a partition key of "LoggingMar2014".

Due to the way Azure charges for transactions, you can save money by batching your records together. If you set batch to be a high value (more than 100?), you may notice a delay in your logging. so think about what you can accept for a time / money trade off and set this value carefully.
Azure maintains a "CreatedAt" attribute with a timestamp, however this will be the time that the batch is sent to the server - not the time the event actually happened. To determine that, use the RowKey instead. Log4r-azure will create records with the RowKey as a Unix timestamp (seconds since epoch). RowKeys are stored as strings in Azure Table Storage, not timestamps, so unfortunately it's still a bit annoying to retrieve, however if you download your logs you can convert the RowKey to a proper timestamp.

## Installation
Make sure you're using log4r already, then add it to your Gemfile:
```ruby
gem 'log4r-azure'
```

You need to feed log4r-azure your storage account and access key. If you're using Rails, you can create an initializer such as config/initializers/azure_logging.rb
```ruby
require 'azure_logging'

Azure.configure do |config|
  config.storage_account_name = "YourAccountName"
  config.storage_access_key = "<put your key here>"
end
```

You can omit the "Azure.configure" block if you set the environment variables instead:
```shell
AZURE_STORAGE_ACCOUNT = <your azure storage account name>
AZURE_STORAGE_ACCESS_KEY = <your azure storage access key>
```

## Usage
You just need to add the AzureOutputter into your logging configuration, just like any other Outputter. For example, to log to a text file, console and Azure:
```yaml
log4r_config:
  # define all loggers ...
  loggers:
    - name      : development
      level     : ALL
      trace     : 'true'
      outputters :
      - file
      - azure
      - console
  outputters:
  - type: StdoutOutputter
    name: console
    formatter:
      date_pattern: '%H:%M:%S'
      pattern     : '%d %l: %m '
      type        : PatternFormatter
  - type: FileOutputter
    name: file
    filename: "log/development.log" # notice the file extension is needed! 
    formatter:
      date_pattern: '%H:%M:%S'
      pattern     : '%d %l: %m '
      type        : PatternFormatter
  - type: AzureOutputter
    name: azure
    batch: 5
    formatter:
      date_pattern: '%H:%M:%S'
      pattern     : '%d %l: %m '
      type        : PatternFormatter
```

## Viewing the log
This gem does not attempt to solve this problem! There isn't a way to view the data from the Azure console yet, but I've been using Visual Studio 2013 as a client, and that works pretty well. I think there are a few clients on codeplex and the like. Please contact me if you find some good ones - I'll list them here.

I hope this gem is useful to someone!
Timothy.
