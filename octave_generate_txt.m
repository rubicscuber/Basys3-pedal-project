num_bits = 16;
num_samples = 2^num_bits;
shape = 20;
txt_filename = sprintf("20tanh_%dx%d.txt",num_bits,num_samples);
mif_filename = sprintf("20tanh_%dx%d.mif",num_bits,num_samples);

tanh_samples = zeros(num_samples, 1);

%used to index i properly
%for 16 bit, (span+1) traverses from -32,768 to 32,767
span = (-1) * num_samples / 2 -1; 

for i = 1:num_samples
    % the formula is y=tanh(ax) where [-0.5<=x<=0.5] and a is constant
    % 
    % 
    % (span+i)/num_samples makes a decimal number from -1/2 to 1/2
    tanh_samples(i) = tanh(shape*(span+i) / num_samples);
endfor

%   normalize the fractional numbers to their large whole numbers 
%   populate with the fullest depth possible from -32,768 to 32,767
%   python script will take all those decimal values to signed binary
max_val = max(tanh_samples);
scale_factor = num_samples / (2 * max_val) - 1;
scaled_samples = 0;
for i = 1:num_samples
  scaled_samples(i) = round(tanh_samples(i) * scale_factor);
endfor

 plot(scaled_samples);
 title('Tanh(20x) plot 16 bit, x set = [-0.5, 0.5]');
 xlabel('Vin');
 ylabel('Vout');

% Write all the large decimal values to txt file
% Run python script with right args to convert to signed bin
function write_to_txt(filename, data, num_bits)
    fid = fopen(filename, 'w');

    for i = 1:length(data)
        stringNum = sprintf('%d', data(i));
        if i < 2^num_bits            
            fprintf(fid, '%s\n', stringNum);
        elseif i == 2^num_bits
            fprintf(fid, '%s', stringNum);
        endif
    endfor
    fclose(fid);
endfunction 

write_to_txt(txt_filename, scaled_samples, num_bits);

