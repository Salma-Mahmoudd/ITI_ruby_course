require 'time'

module Logger
    def log_info(msg)
        File.open("app.logs", "a") do |file|
            file.puts("#{Time.now.iso8601} -- info -- #{msg}")
        end
    end

    def log_warning(msg)
        File.open("app.logs", "a") do |file|
            file.puts("#{Time.now.iso8601} -- warning -- #{msg}")
        end
    end

    def log_error(msg)
        File.open("app.logs", "a") do |file|
            file.puts("#{Time.now.iso8601} -- error -- #{msg}")
        end
    end
end

#___________________________________________________________

class User 
    attr_accessor :name, :balance

    def initialize(name, balance)
        @name = name
        @balance = balance
    end
end

#___________________________________________________________

class Transaction
    attr_reader :user, :value

    def initialize(user, value)
        @user = user
        @value = value
    end
end

#___________________________________________________________

class Bank
    def initialize
        raise NotImplementedError, "This is an abstract class. Implement in subclasses." if instance_of?(Bank)
    end

    def process_transactions(transactions, &block)
        raise NotImplementedError, "This is an abstract method. Implement in subclasses."
    end
end

#___________________________________________________________

class CBABank < Bank
    include Logger
    @@users = []

    def self.users=(users)
        @@users = users
    end

    def process_transactions(transactions, &block)
        log_info("Processing Transactions #{transactions.map { |trans| "User #{trans.user.name} transaction with value #{trans.value}" }.join(", ")}")

        transactions.each do |trans|
            begin
                unless @@users.include?(trans.user)
                    raise "Not exists in the bank!!"
                end

                new_balance = trans.user.balance + trans.value

                if new_balance < 0
                    raise "Not enough balance"
                end
                
                trans.user.balance = new_balance
                log_info("User #{trans.user.name} transaction with value #{trans.value} succeeded")

                log_warning("#{trans.user.name} has 0 balance") if new_balance == 0

                block.call true, trans, nil
            rescue => e
                log_error("User #{trans.user.name} transaction with value #{trans.value} failed with message #{e.message}")
                block.call false, trans, e.message
            end
        end
    end
end

#___________________________________________________________

users = [
  User.new("Ali", 200),
  User.new("Peter", 500),
  User.new("Manda", 100)
]

out_side_bank_users = [
    User.new("Menna", 400),
]

transactions = [
    Transaction.new(users[0], -20),
    Transaction.new(users[0], -30),
    Transaction.new(users[0], -50),
    Transaction.new(users[0], -100),
    Transaction.new(users[0], -100),
    Transaction.new(out_side_bank_users[0], -100)
]

CBABank.users = users
bank = CBABank.new

bank.process_transactions(transactions) { |success, trans, msg| puts("Call endpoint for #{success ? 'success' : 'failure'} for #{trans.user.name} transaction with value #{trans.value} #{msg ? 'with reason ' + msg : ''}") }