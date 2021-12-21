function [directors, integrators, segregators] = directing_triads(FC, roi)

% FC is a n * n symetric correlation matrix, containing two or more subnetworks, roi of which are respectively given as an array: roi

% A node "i" in the 1st network is directing if,
% it is positivly connected with two nodes in the 2nd network (j and k where, FC(i,j) > 0 and FC(i,k) > 0),
% who are negatively connected (FC(j,k) < 0). These three nodes (i, j, k) form a triad that we call a directing triad.

% Returns two matrices, 4*n and 4*m.
% Rows 1 to 3 are i, j, k nodes of the directing triad, and the 4th row is the weight (energy) of this directing triad.
% Cols are each directing triads which are n for directing triads from the 1st to 2nd network and m vice versa.

count_subnets = numel(roi);

if count_subnets == 3
    count_directors = [1, 1, 1];
    count_segregators = 1;
    count_integrators = 1;

    for i = 1:roi(1, 1)
        for j = (roi(1, 1) + 1):(roi(1, 1) + roi(1, 2))
            for k = (roi(1, 1) + roi(1, 2) + 1):sum(roi)
                a = FC(i, j);
                b = FC(j, k);
                c = FC(i, k);            
                if a > 0 && b < 0 && c > 0
                    directors{1, 1}(:, count_directors(1, 1)) = setter(i, j, k, a, b, c); % directing triad from the 1st subnet
                    count_directors(1, 1) = count_directors(1, 1) + 1;
                elseif a > 0 && b > 0 && c < 0
                    directors{1, 2}(:, count_directors(1, 2)) = setter(i, j, k, a, b, c); % directing triad from the 2nd subnet
                    count_directors(1, 2) = count_directors(1, 2) + 1;
                elseif a < 0 && b > 0 && c > 0
                    directors{1, 3}(:, count_directors(1, 3)) = setter(i, j, k, a, b, c); % directing triad from the 3rd subnet
                    count_directors(1, 3) = count_directors(1, 3) + 1;
                elseif a > 0 && b > 0 && c > 0
                    integrators{1, 1}(:, count_integrators) = setter(i, j, k, a, b, c);
                    count_directors = count_integrators + 1;
                elseif a < 0 && b < 0 && c < 0
                    segregators{1, 1}(:, count_segregators) = setter(i, j, k, a, b, c);
                    count_segregators = count_segregators + 1;                
                end
            end
        end   
    end

elseif count_subnets == 2
    count_directors = [1, 1];
    count_segregators = [1, 1];
    count_integrators = [1, 1];
    indexes = {[1, roi(1, 1)], [(roi(1, 1) + 1), (sum(roi) - 1)], [0, sum(roi)]; [(roi(1, 1) + 1), sum(roi)], [1, (roi(1, 1) - 1)], [0, roi(1, 1)]};
    for direction = 1:2 % 1: from 1st to 2nd subnet, 2:from 2nd to 1st subnet
        for i = indexes{direction, 1}(1, 1):indexes{direction, 1}(1, 2)
            for j = indexes{direction, 2}(1, 1):indexes{direction, 2}(1, 2)
                for k = j+1:indexes{direction, 3}(1, 2)
                    a = FC(i, j);
                    b = FC(j, k);
                    c = FC(i, k);            
                    if a > 0 && b < 0 && c > 0
                        directors{1, direction}(:, count_directors(1, direction)) = setter(i, j, k, a, b, c); % directing triad from the 1st to 2nd subnet when direction = 1, and from 2nd to 1t when direction = 2
                        count_directors(1, direction) = count_directors(1, direction) + 1;  
                    elseif a > 0 && b > 0 && c > 0
                        integrators{1, direction}(:, count_integrators(1, direction)) = setter(i, j, k, a, b, c); % integrating triad from the 1st to 2nd subnet when direction = 1, and from 2nd to 1t when direction = 2
                        count_integrators(1, direction) = count_integrators(1, direction) + 1;                          
                    elseif a < 0 && b < 0 && c < 0
                        segregators{1, direction}(:, count_segregators(1, direction)) = setter(i, j, k, a, b, c); % segregating triad from the 1st to 2nd subnet when direction = 1, and from 2nd to 1t when direction = 2
                        count_segregators(1, direction) = count_segregators(1, direction) + 1;                          
                    end                   
                end                
            end
        end               
    end    
end

end

function [output] = setter(i, j, k, a, b, c)
% Sets the directing triads column-wise, that is, each col repesents a directing triad in four rows:
% 1-3: Index of its nodes i,j,k and 4: Weight (or the so-called energy) of the directing triad.
output(1, 1) = i;
output(2, 1) = j;
output(3, 1) = k;
output(4, 1) = - a * b * c;
end


