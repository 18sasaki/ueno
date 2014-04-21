
module RaiseCatch
  def find(id)
    begin
      super(id)
    rescue => e
      p "raise : #{e}"
      nil
    end
  end
end
