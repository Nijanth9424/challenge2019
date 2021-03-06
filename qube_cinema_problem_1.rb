require 'csv'
csv_data = CSV.read(Dir.pwd + "/partners.csv")
data_set = []
csv_data.each_with_index do |data, index|
  next if index.zero?
  data_set << {
      theatre: data[0].strip,
      size_slab: data[1].strip.split('-').map(&:to_i),
      min_cost: data[2].strip.to_i,
      cost_per_gb: data[3].strip.to_i,
      partner_id: data[4].strip
  }
end
input_data_1 = CSV.read(Dir.pwd + "/input.csv")
deliveries = []
input_data_1.each do |input|
  deliveries << {
      delivery: input[0],
      size: input[1].to_i,
      theatre: input[2]
  }
end
CSV.open(Dir.pwd + "/#{ARGV[0]}.csv", "a+") do |output|
  output << %w[Delivery Possibility Partner Cost]
  deliveries.each do |delivery|
    cost = ""
    possibility = false
    partner = ""
    valid_by_theatre = data_set.select{|key| key[:theatre] == "#{delivery[:theatre]}"}
    data_size = delivery[:size]
    @valid_by_size = valid_by_theatre.select{|key| data_size.between?(key[:size_slab][0], key[:size_slab][1])}

    if !@valid_by_size.empty?
      cost_for_each = @valid_by_size.map{|data| {"#{data[:partner_id]}": data[:cost_per_gb] * delivery[:size]} }
      final_pair = cost_for_each.first
      cost_for_each.each {|cp| final_pair = cp if cp.values.last < final_pair.values.last }
      partner = final_pair.keys.last
      possibility = true

      cost = [final_pair.values.last, 2000].max
    end

    output << ["#{delivery[:delivery]}", "#{possibility}", "#{partner}", "#{cost}"]
  end
end



