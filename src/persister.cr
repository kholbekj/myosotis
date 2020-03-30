class Persister

  def initialize(@file_name : String)
  end

  def persist(q_and_a_hash)
    File.write(file_name, q_and_a_hash.to_json)
  end

  def read_answer(file, question)
    json = JSON.parse(File.read(file))
    any = json[question]?
    any.as_s if any
  end

  def file_name
    @file_name
  end
end
