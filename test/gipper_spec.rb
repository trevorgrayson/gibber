require File.expand_path('../../lib/gipper', __FILE__)

describe Gipper do
  let(:first) { {a: "a", b: "b"} }
  let(:last)  { {a: "A", b: "B"} }

  verify_args = [
    [:a],
    [:a, :b],
    (0..rand(3..10)).map{|i| i.chr }
  ]

  context 'verifies' do

    verify_args.each do |arg|
      it "#{arg.count} arguments" do
        logger = double("logger")
        expect(logger).to receive(:error).exactly(1).times

        Gipper.logger = logger

        expect{
          Gipper.review do
            verify *arg
          end
        }.to raise_error(GipperError)
      end
    end

  end

  context 'trusts' do

    verify_args.each do |arg|
      it "#{arg.count} arguments" do
        logger = double("logger")
        expect(logger).to receive(:warn).exactly(arg.count).times

        Gipper.logger = logger
        Gipper.review do
          trust *arg
        end

      end
    end

  end

  context 'cascade sets' do
    it 'last set out' do
      GIP = Gipper.review first, last do
        verify :a
      end

      last.each do |k,v|
        expect(GIP[k]).to eq last[k]
      end
    end

  end

  context 'env' do
    let(:key) { "a" }
    let(:key2) { "env" }
    let(:config) { 
      {}.tap{ |c| c[key] = "bullpit" }
    }

    it 'defaults to ENV' do
      ENV[key]  = "env"
      ENV[key2] = "env"

      gip = Gipper.review config do 
      end

      expect(gip[key]).to eq( config[key] )
      expect(gip[key2]).to eq("env")
    end

    it 'exports a config' do
    end
  end

  context 'verify services' do
    
    before(:each) do
      Gipper.logger = double("logger")
    end

    it 'throws on missing services' do
      ENV["DATABASE_URL"] = "postgres://postgres:password@localhost:60001/some_db"
      uri = URI.parse(ENV["DATABASE_URL"])

      expect{
        Gipper.review do
          verify_service :DATABASE_URL
        end
      }.to raise_error #(GipperError)

    end

    it 'runs block on missing service' do
      ENV["DATABASE_URL"] = "postgres://postgres:password@localhost:60001/some_db"
      uri = URI.parse(ENV["DATABASE_URL"])

      expect{
        Gipper.review do
          verify_service :DATABASE_URL do
            Counter.inc
          end
        end
      }.to raise_error #(GipperError)

      expect(Counter.count).to eq(1)
    end

    it 'throws custom error message' do
      skip
      ENV["DATABASE_URL"] = "postgres://postgres:password@localhost:60001/some_db"
      uri = URI.parse(ENV["DATABASE_URL"])

      error_msg = "Oopsidoodle!"

      expect{
        Gipper.review do
          verify_service :DATABASE_URL#, :error_message => error_msg
        end
      }.to raise_error #(GipperError)

    end

    it 'verifies good services' do
      ENV["DATABASE_URL"] = "postgres://postgres:password@localhost:60001/some_db"
      uri = URI.parse(ENV["DATABASE_URL"])

      serve(uri.port)

      Gipper.review do
        verify_service :DATABASE_URL
      end

    end
  end

  def serve(port)
    Thread.new do

      server = TCPServer.open(port)
      Thread.start(server.accept) do |client|
        client.close
      end
    end
  end

end
