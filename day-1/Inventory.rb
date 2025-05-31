class Inventory
  attr_accessor :file_name

    def initialize(file_name)
        @file_name = file_name
        File.write(@file_name, '') unless File.exist?(@file_name)
    end

    def add_book(isbn, title, author)
        books = get_books
        existing = books.find { |book| book.start_with?(isbn + ':') }
        if existing
            count = existing.chomp.split(':')[3]
            updated_books = books.map { |book| book.start_with?(isbn + ':') ? "#{isbn}:#{title}:#{author}:#{count.to_i + 1}" : book.chomp }
            File.write(@file_name, updated_books.join("\n"))
        else
            File.open(@file_name, 'a') { |f| f.puts "#{isbn}:#{title}:#{author}:1" }
        end
        sort_books
    end

    def remove_book(isbn)
        books = get_books.reject { |line| line.start_with?(isbn + ':') }
        File.write(@file_name, books.join(''))
    end

    def get_books
        File.readlines(@file_name)
    end

    def sort_books
        sorted = get_books.sort_by { |book| book.split(':')[0].to_i }
        File.write(@file_name, sorted.join(''))
    end

    def search_by(field, value)
        get_books.select do |book|
            parts = book.split(':')
            case field
            when :isbn then parts[0].include?(value)
            when :title then parts[1].downcase.include?(value.downcase)
            when :author then parts[2].downcase.include?(value.downcase)
            end
        end
    end
end





#___________________________________________________________

def prompt(message)
  print message
  gets.chomp.strip
end

def display_books(books)
    if books.empty?
        puts "No books found.\n\n"
    else
        puts "Books in Inventory:"
        puts "___________________\n\n"
        books.each do |book|
            isbn, title, author, count = book.split(':')
            puts " - ISBN: #{isbn}, Title: #{title}, Author: #{author}, Count: #{count}"
        end
        puts "\n"
    end
end

file_name = prompt("Enter your file name (default is 'books.txt'): ")
file_name = 'books.txt' if file_name.empty?
inventory = Inventory.new(file_name)

while true
    print "
    1. Add Book
    2. Remove Book
    3. List Books
    4. Search Book by ISBN
    5. Search Book by Title
    6. Search Book by Author
    7. Exit

    > "

    case gets.chomp.to_i
    when 1
        isbn = prompt("Enter ISBN: ")
        title = prompt("Enter Title: ")
        author = prompt("Enter Author: ")
        if [isbn, title, author].any?(&:empty?)
            puts "All fields are required. Please try again.\n\n"
        else
            inventory.add_book(isbn, title, author)
            puts "Book added successfully!\n\n"
        end

    when 2
        isbn = prompt("Enter ISBN to remove: ")
        if isbn.empty?
            puts "ISBN is required to remove a book. Please try again.\n\n"
        else
            books = inventory.search_by(:isbn, isbn)
            if books.empty?
                puts "No book found with ISBN #{isbn}.\n\n"
            else
                confirmation = prompt("Type 'y' to confirm removal: ")
                if confirmation.downcase == 'y'
                    inventory.remove_book(isbn)
                    puts "Book with ISBN #{isbn} removed successfully!\n\n"
                else
                    puts "Removal cancelled.\n\n"
                end
            end
        end

    when 3
        display_books(inventory.get_books)

    when 4
        isbn = prompt("Enter ISBN to search: ")
        books = inventory.search_by(:isbn, isbn)
        display_books(books)

    when 5
        title = prompt("Enter Title to search: ")
        books = inventory.search_by(:title, title)
        display_books(books)

    when 6
        author = prompt("Enter Author to search: ")
        books = inventory.search_by(:author, author)
        display_books(books)
    
    when 7
        puts "Exiting the program. Goodbye!"
        exit

    else
        puts "Invalid choice. Please try again.\n\n> "
    end
end