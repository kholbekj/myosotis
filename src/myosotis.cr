require "option_parser"
require "json"

module Myosotis
  VERSION = "0.1.0"

  art = <<-HERE
                  _  /)
                 mo / )
                 |/)\)
                  /\_
                  \__|=
                 (    )
                 __)(__
           _____/      \\_____
          |                  ||
          |                  ||
          |     -Forget-     ||
          |                  ||
          |       -Me-       ||
          |                  ||
          |      -Not-       ||
          |                  ||
          |                  ||
  *       | *   **    * **   |**      **
   \))ejm96/.,(//,,..,,\||(,,.,\\,.((//
  HERE

  intro_text = <<-HERE
  Welcome to interactive mode!
  To add questions, simply enter a question, press enter, and then a reply!
  When it feels done, just hit ctrl+c to cut it out!
  HERE

  read_text = <<-HERE
  Welcome to interactive mode!
  To find anwers, simply ask a question, then press enter!
  HERE

  @@file_name : String = "output/#{Random.new.hex(8)}.myo"

  OptionParser.parse do |parser|
    parser.banner = "Forget me not."

    parser.on "-c", "--create-interactive", "Create in interactive  mode" do
      slow_print(art)
      puts
      sleep(1)
      slow_print(intro_text, 2.0)
      questions = Hash(String, String).new
      loop do
        print "Question: "
        q = gets
        print "Answer: "
        a = gets
        next unless q && a
        questions[q] = a
        persist(questions)
      end
      exit
    end

    parser.on "-r FILE", "--read-interactive=FILE", "Read in interactive  mode" do |file|
      slow_print(art)
      puts
      sleep(1)
      slow_print(read_text, 2.0)
      loop do
        print "Question: "
        q = gets
        unless q
          next 
        end
        answer = read_answer(file, q)
        unless answer
          puts "No answer to that." 
          next
        end
        puts "Answer: #{answer}"
      end
      exit
    end
    
    parser.on "-h", "--help", "Display this message" do
      puts parser
      exit
    end

    parser.unknown_args do
      puts parser
      exit
    end
  end

  def self.slow_print(text)
    text.lines.each do |line|
      puts line
      sleep(0.05)
    end
  end

  def self.slow_print(text, interval)
    text.lines.each do |line|
      puts line
      sleep(interval)
      puts
    end
  end

  def self.persist(q_and_a_hash)
    File.write(file_name, q_and_a_hash.to_json)
  end

  def self.read_answer(file, question)
    json = JSON.parse(File.read(file))
    any = json[question]?
    any.as_s if any
  end

  def self.file_name
    @@file_name
  end
end
