require 'azure'
require 'log4r/outputter/outputter'
require 'log4r/staticlogger'

module Log4r
  class AzureOutputter < Outputter
    
    attr_reader :vars
    attr_reader :table
    attr_accessor :partition_key
    attr_accessor :batch_count
    attr_accessor :batched_records
    attr_accessor :last_record

    def initialize(_name, hash={})
      super(_name, hash)
      validate(hash)
      @batched_records = []
      @hostname = (`hostname -f`).chomp # For some strange reason, Socket.gethostname seems to get inserted as a Byte[] Array into the Azure Table? I can't figure it out, so I'm using this ugly hack instead.
    end

    # Need to handle transient failure...
    def flush
      Logger.log_internal { "Inserting #{@batch_count} records into #{@table}" }
      batch = Azure::Table::Batch::new @table, @partition_key
      @batched_records.each do |record|
        batch.insert record["RowKey"], record.reject { |k| k == "RowKey" }
      end
      result = @azure_table.execute_batch batch
      @batched_records = []
    end

    private

      def validate(hash)
        Logger.log_internal { "Validating params" }
        @table = hash['table'] ||= "logging"
        @azure_table = Azure::TableService.new
        create_or_use_table
        @partition_key = "Logging#{Date.today.strftime('%b%Y')}"
        @batch_count = hash['batch'] ||= 1
      end

      def canonical_log(logevent)
        write(logevent)
      end

      def write(logevent)
        message = logevent.data.force_encoding("utf-8").strip
        data = { "message" => message }
        key = (DateTime.now.to_time.to_f * 1000).to_i
        @batched_records << data.merge("RowKey" => key.to_s).merge("hostname" => @hostname)
        Logger.log_internal { data }

        if(@batched_records.count < @batch_count)
          Logger.log_internal { "Added to batch. Waiting for #{@batch_count - @batched_records.count} records before insert" } 
        else
          Thread.new { flush }
        end
      end

      def create_or_use_table
        Logger.log_internal { "Using table #{@table}" }
        Logger.log_internal { "Using account #{Azure.config.storage_account_name}" }
        begin
          @azure_table.get_table(@table)
        rescue Exception => e
          Logger.log_internal { e }
          @azure_table.create_table(@table) #if e.type == "ResourceNotFound"
        end
      end
  end
end
