module Lex
  def self.tokenize(s)
    scanner = scanner(s)

    return (1..s.size).inject([]) { |toks, _| toks.push scanner.next }
  end

  def self.scanner(s)
    return enum_for(__method__, s) unless block_given?

    chars = s.split(//)

    while chars.size > 0
      yield chars.shift
    end

    nil
  end
end

class MetasploitModule < Msf::Auxiliary
  def initialize(info = {})
    super(
      update_info(
        info,
        'Name'        => 'Test Ruby 2.5 enum bug on Win',
        'Description' => 'Enum calls in nested threads breaks Ruby 2.5 on Win',
        'Author'      => ['Test Armstrong <tarm@example.com>'],
        'License'     => MSF_LICENSE,
      )
    )
    register_options(
      [
        OptString.new('STRING', [ true, "Test input string", "abcdef"]),
        OptInt.new('THREADS', [ true, "Number of nested threads (0-2)", 0]),
      ]
    )
  end

  def run
    print_status("Running Ruby 2.5 enum bug test.")

    s = datastore['STRING']

    case datastore['THREADS']
    when 0
      tokens = Lex.tokenize(s)
    when 1
      tokens = Thread.new do
        Lex.tokenize(s)
      end.value
    when 2
      tokens = Thread.new do
        Thread.new do
          Lex.tokenize(s)
        end.value
      end.value
    else
      print_error("The number of threads must be between 0 and 2.")
      return
    end

    print_status(tokens.inspect)
  end
end
