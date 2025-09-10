num_bits = 24;
num_samples = 2^num_bits;
shape = 4;
txt_filename = sprintf("tanh_%dx%d.txt",num_bits,num_samples);
mif_filename = sprintf("tanh_%dx%d.mif",num_bits,num_samples);

tanh_samples = zeros(num_samples, 1);
span = (-1) * num_samples / 2 -1; %used to index i properly

for i = 1:num_samples
    % (span+i)/num_samples makes a decimal number from -1 to 1
    %
    % shape is a constant multiple that changes the graph
    tanh_samples(i) = tanh(shape*(span+i) / num_samples);
end

%   normalize the fractional numbers to whole numbers 
%   that occupy the fullest depth possible from -2047 to 2048

%   if its unsigned, the range is 0 to 4096
%   then scale_factor = num_samples/max_val;
max_val = max(tanh_samples);
scale_factor = num_samples / 2 / max_val - 1;
scaled_samples = 0;

for i = 1:num_samples
  scaled_samples(i) = round(tanh_samples(i) * scale_factor);
end

% plot(scaled_samples);
% title('Tanh plot 24 bit');
% xlabel('Vin');
% ylabel('Vout');

write_to_txt(txt_filename, scaled_samples, num_bits);

%need supported version of CPython
%py.to_bin.convert(output_filename, mif_filename, num_bits);

function write_to_txt(filename, data, num_bits)
    fid = fopen(filename, 'w');

    for i = 1:length(data)
        stringNum = sprintf('%d', data(i));
        if i < 2^num_bits            
            fprintf(fid, '%s\n', stringNum);
        elseif i == 2^num_bits
            fprintf(fid, '%s', stringNum);
        end
    end
    fclose(fid);
end 



