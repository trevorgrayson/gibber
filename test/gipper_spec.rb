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
          Gipper.new do
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
        Gipper.new do
          trust *arg
        end

      end
    end

  end

  context 'cascade sets' do
    it 'last set out' do
      gipper = Gipper.new first, last do
        verify :a
      end

      last.each do |k,v|
        expect(gipper.env[k]).to eq last[k]
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

      gipper = Gipper.new config do 
      end

      expect(gipper.env[key]).to eq( config[key] )
      expect(gipper.env[key2]).to eq("env")
    end

    it 'exports a config' do
    end
  end

end
