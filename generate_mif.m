num_bits = 12;
num_samples = 2^num_bits;
shape = 4;
output_filename = sprintf("tanh_%dx%d.mif",num_bits,num_samples);

tanh_samples = zeros(num_samples, 1);
span = (-1) * num_samples / 2 -1;

for i = 1:num_samples
    %each value of i is shifted evenly around 0 then scaled to the proper step size
    %shape is a constant multiple that changes the steepness of the graph
    tanh_samples(i) = tanh(shape*(span+i) / num_samples);
endfor

max_val = max(tanh_samples);
scale_factor = num_samples / 2 / max_val - 1;

% 
for i = 1:num_samples
  scaled_samples(i) = round(tanh_samples(i) * scale_factor);
endfor

plot(scaled_samples);
title('Tanh plot 24 bit');
xlabel('Vin');
ylabel('Vout');

function write_to_mif(filename, data, bit_width)
    fid = fopen(filename, 'w');

    for i = 1:length(data)
        bin_str = dec2bin(data(i), bit_width);
        fprintf(fid, '%s\n', bin_str);
    endfor

    fclose(fid);

endfunction

write_to_mif(output_filename, scaled_samples, num_bits);

