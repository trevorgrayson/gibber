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

      GIP = Gipper.review config do 
      end

      expect(GIP[key]).to eq( config[key] )
      expect(GIP[key2]).to eq("env")
    end

    it 'exports a config' do
    end
  end

end
