require_relative '../earthquake'
require 'haversine'
require 'rspec'

describe Earthquake do
  describe '#initialize' do
    it 'sets @imported_data to an empty array' do
      expect(described_class.new.instance_variable_get(:@imported_data)).to eq []
    end

    it 'sets @earthquake_data to an empty array' do
      expect(described_class.new.instance_variable_get(:@earthquake_data)).to eq []
    end
  end

  describe '#compile_data_from_csv' do
    context 'with no earthquakes in csv' do
      let(:no_earthquake_data) {
        [
          ["2017-02-15T18:20:54.650Z", "36.5929985", "-121.1346664", "9.06", "1.62", "md", "14", "95", "0.0779", "0.06", "nc", "nc72764551", "2017-02-15T19:04:03.572Z", "25km NE of Soledad, California", "not_an_earthquake", "0.29", "0.95", "0.4", "12", "automatic", "nc", "nc"],
          ["2017-02-15T18:01:14.942Z", "37.1418", "-117.0675", "7.7", "1.6", "ml", "34", "51.15", "0.164", "0.1987", "nn", "nn00578547", "2017-02-15T18:21:41.380Z", "37km NW of Beatty, Nevada", "not_an_earthquake", nil, "1.9", "0.23", "14", "reviewed", "nn", "nn"]
        ]
      }

      it 'returns an empty array' do
        allow_any_instance_of(described_class).to receive(:import_data_from_csv).and_return(no_earthquake_data)

        expect(described_class.new.compile_data_from_csv('')).to eq []
      end
    end

    context 'with earthquakes in csv' do
      context 'and earthquakes too far' do
        let(:earthquake_data) {
          [
            ["2017-02-15T18:20:54.650Z", "36.5929985", "-121.1346664", "9.06", "1.62", "md", "14", "95", "0.0779", "0.06", "nc", "nc72764551", "2017-02-15T19:04:03.572Z", "25km NE of Soledad, California", "earthquake", "0.29", "0.95", "0.4", "12", "automatic", "nc", "nc"],
            ["2017-02-15T18:01:14.942Z", "37.1418", "-117.0675", "7.7", "1.6", "ml", "34", "51.15", "0.164", "0.1987", "nn", "nn00578547", "2017-02-15T18:21:41.380Z", "37km NW of Beatty, Nevada", "earthquake", nil, "1.9", "0.23", "14", "reviewed", "nn", "nn"]
          ]
        }

        it 'returns an empty array' do
          allow_any_instance_of(described_class).to receive(:import_data_from_csv).and_return(earthquake_data)

          expect(described_class.new.compile_data_from_csv('')).to eq []
        end
      end

      context 'and earthquakes not too far' do
        let(:earthquake_data) {
          [
            ["2017-02-15T18:20:54.650Z", "36.5929985", "-121.1346664", "9.06", "2.4", "md", "14", "95", "0.0779", "0.06", "nc", "nc72764551", "2017-02-15T19:04:03.572Z", "25km NE of Soledad, California", "earthquake", "0.29", "0.95", "0.4", "12", "automatic", "nc", "nc"],
            ["2017-02-15T18:01:14.942Z", "37.1418", "-117.0675", "7.7", "2.3", "ml", "34", "51.15", "0.164", "0.1987", "nn", "nn00578547", "2017-02-15T18:21:41.380Z", "37km NW of Beatty, Nevada", "earthquake", nil, "1.9", "0.23", "14", "reviewed", "nn", "nn"]
          ]
        }
        let(:compiled_data) { described_class.new.compile_data_from_csv('') }

        it 'returns valid earthquake data' do
          allow_any_instance_of(described_class).to receive(:import_data_from_csv).and_return(earthquake_data)

          expect(compiled_data.length).to eq 2
          expect(compiled_data.first[3]).to eq '2.3' # Magnitude
          expect(compiled_data.last[3]).to eq '2.4' # Magnitude
        end
      end
    end
  end

  describe '#find_earthquakes_felt_in_la' do
    let(:instance) { described_class.new }

    before do
      allow_any_instance_of(described_class).to receive(:import_data_from_csv).and_return(good_data)
      instance.compile_data_from_csv
    end

    it 'returns a maximum of 10 results' do
      expect(instance.earthquake_data.length).to eq 11
      expect(instance.find_earthquakes_felt_in_la.length).to eq 10
    end

    it 'returns the results sorted by date and by time' do
      expected_data = instance.find_earthquakes_felt_in_la.sort_by do |e|
        [e[0], e[1]]
      end.first(10)

      expect(instance.find_earthquakes_felt_in_la).to eq expected_data
    end
  end
end

private

def good_data
  [
    ["2017-02-15T18:20:54.650Z", "36.5929985", "-121.1346664", "9.06", "100.62", "md", "14", "95", "0.0779", "0.06", "nc", "nc72764551", "2017-02-15T19:04:03.572Z", "25km NE of Soledad, California", "earthquake", "0.29", "0.95", "0.4", "12", "automatic", "nc", "nc"],
    ["2017-02-15T18:01:14.942Z", "37.1418", "-117.0675", "7.7", "100.6", "ml", "34", "51.15", "0.164", "0.1987", "nn", "nn00578547", "2017-02-15T18:21:41.380Z", "37km NW of Beatty, Nevada", "earthquake", nil, "1.9", "0.23", "14", "reviewed", "nn", "nn"],
    ["2017-02-15T17:58:14.520Z", "-59.3725", "149.2253", "10", "400.8", "mb", nil, "136", "7.221", "0.6", "us", "us20008k14", "2017-02-15T18:19:28.040Z", "West of Macquarie Island", "earthquake", "6", "1.9", "0.109", "26", "reviewed", "us", "us"],
    ["2017-02-15T17:48:53.140Z", "60.9336", "-150.827", "40.5", "100.6", "ml", nil, nil, nil, "0.47", "ak", "ak15273701", "2017-02-15T17:53:13.071Z", "36km NE of Nikiski, Alaska", "earthquake", nil, "0.8", nil, nil, "automatic", "ak", "ak"],
    ["2017-02-15T17:41:33.210Z", "36.02", "-117.7773333", "2.18", "100.01", "ml", "13", "124", "0.01108", "0.11", "ci", "ci37584183", "2017-02-15T18:38:58.892Z", "15km NE of Little Lake, CA", "earthquake", "0.23", "0.17", "0.082", "4", "reviewed", "ci", "ci"],
    ["2017-02-15T17:31:30.640Z", "-21.6959", "-68.3404", "133.31", "400.3", "mb", nil, "31", "0.844", "0.54", "us", "us20008k0t", "2017-02-15T18:55:33.040Z", "105km NE of Calama, Chile", "earthquake", "6.6", "8.9", "0.161", "11", "reviewed", "us", "us"],
    ["2017-02-15T17:19:07.760Z", "40.2823334", "-124.3860016", "19.27", "200.85", "md", "11", "291", "0.08728", "0.08", "nc", "nc72764531", "2017-02-15T17:46:04.005Z", "33km SW of Rio Dell, California", "earthquake", "2.58", "0.7", "0.11", "5", "automatic", "nc", "nc"],
    ["2017-02-15T17:19:06.990Z", "59.8817", "-151.4794", "71.7", "100.8", "ml", nil, nil, nil, "0.51", "ak", "ak15273310", "2017-02-15T17:33:03.348Z", "19km NNW of Fritz Creek, Alaska", "earthquake", nil, "1.3", nil, nil, "automatic", "ak", "ak"],
    ["2017-02-15T17:07:38.470Z", "38.8216667", "-122.7965012", "1.42", "100.88", "md", "9", "112", "0.01074", "0.02", "nc", "nc72764526", "2017-02-15T17:34:02.127Z", "6km W of Cobb, California", "earthquake", "0.39", "0.79", nil, "1", "automatic", "nc", "nc"],
    ["2017-02-15T16:44:38.510Z", "59.6599", "-152.3616", "71.9", "100.9", "ml", nil, nil, nil, "0.53", "ak", "ak15273306", "2017-02-15T17:03:01.387Z", "32km WSW of Anchor Point, Alaska", "earthquake", nil, "0.7", nil, nil, "automatic", "ak", "ak"],
    ["2017-01-01T16:44:38.510Z", "59.6599", "-152.3616", "71.9", "100.9", "ml", nil, nil, nil, "0.53", "ak", "ak15273306", "2017-02-15T17:03:01.387Z", "32km WSW of Anchor Point, Alaska", "earthquake", nil, "0.7", nil, nil, "automatic", "ak", "ak"]
  ]
end
