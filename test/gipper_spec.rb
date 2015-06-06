require File.expand_path('../../lib/gipper', __FILE__)

describe Gipper do
  let(:first) { {a: "a", b: "b"} }
  let(:last)  { {a: "A", b: "B"} }

  context 'verifies' do
    it 'one' do
      expect{
        Gipper.new do
          verify :a
        end
      }.to raise_error(GipperError)
    end

    it 'two' do
      expect{
        Gipper.new do
          verify :a, :b
        end
      }.to raise_error(GipperError)
    end

    it 'many' do
      expect{
        Gipper.new do
          verify :a, :b, :c, :d
        end
      }.to raise_error(GipperError)
    end
  end

  context 'cascade sets' do
    it 'last set out' do
      gipper = Gipper.new first, last do
        #verify :a
      end

      last.each do |k,v|
        expect(gipper.env[k]).to eq last[k]
      end
    end

  end

  context 'env' do
    let(:key) { "a" }
    let(:env_var) { "bullpen" }

    it 'defaults to ENV' do
      ENV[key] = env_var

      gipper = Gipper.new do 
      end

      expect(gipper.env[key]).to eq(env_var)
    end
  end
end
