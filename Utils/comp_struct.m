function [fs1, fs2, er] = comp_struct(s1,s2,n1,n2,p,tol)
% check two structures for differances - i.e. see if strucutre s1 == structure s2
% function [fs1, fs2, er] = comp_struct(s1,s2,n1,n2,p,tol)
%
% inputs  6 - 5 optional
% s1      structure one                              class structure
% s2      structure two                              class structure - optional
% n1      first structure name (variable name)       class char - optional
% n2      second structure name (variable name)      class char - optional
% p       pause flag (0 / 1)                         class integer - optional
% tol     tol default tolerance (real numbers)       class integer - optional
%
% outputs 3 - 3 optional
% fs1     non-matching feilds for structure one      class cell - optional
% fs2     non-matching feilds for structure two      class cell - optional
% er      error flag (value)                         class 
%
% example:      [r1 r2] = comp_struct(data1,data2,'data1','data2',1)
% Created michael arant - april 5 2003
% Modified by jay dubb - january, 21,2011
%
% Hint:
% passing just one structure causes the program to copy the structure
% and compare the two.  This is an easy way to list the structure
%


mode=0;

if nargin < 1; help comp_struct; error('I / O error'); end
if nargin < 2; s2 = s1; end
if nargin < 3; n1 = 's1'; end
if nargin < 4; n2 = 's2'; end
if nargin < 5; p = 0; elseif p ~= 1 && p ~= 0; p = 0; end
if nargin < 6; tol = 1e-6; end

% define fs
fs1 = {}; fs2 = {}; er = {};

% are the variables structures
if isstruct(s1) && isstruct(s2) && (length(s1) == length(s2))

    if(isempty(s1))
        return;
    end

    % both structures - get the field names
    fn1 = sort(fieldnames(s1));
    fn2 = sort(fieldnames(s2));

    % loop through structure 1 and match to structure 2
    pnt1 = zeros(1,length(fn1));
    for ii = 1:length(fn1)
        for jj = 1:length(fn2)
            if strcmp(fn1(ii),fn2(jj)); pnt1(ii) = jj; end
        end
    end
    pnt2 = zeros(1,length(fn2));
    for ii = 1:length(fn2)
        for jj = 1:length(fn1)
            if strcmp(fn2(ii),fn1(jj)); pnt2(ii) = jj; end
        end
    end

    % get un-matched fields
    for ii = find(~pnt1)
        fs1 = [fs1; {[char(n1) '.' char(fn1(ii))]}];
        fs2 = [fs2; {''}]; er = [er; {'Un-matched'}];
    end
    for ii = find(~pnt2)
        fs2 = [fs2; {[char(n2) '.' char(fn2(ii))]}];
        fs1 = [fs1; {''}]; er = [er; {'Un-matched'}];
    end

    pnt1i = find(pnt1); pnt2i = find(pnt2);
    for ii=1:numel(pnt1i)
        % added loop for indexed structured variables
        for jj = 1:size(s1,2)
            % clean display - add index if needed
            if size(s1,2) == 1
                n1p = [n1 '.' char(fn1(pnt1i(ii)))];
                n2p = [n2 '.' char(fn2(pnt2i(ii)))];
            else
                n1p = [n1 '(' num2str(jj) ').' char(fn1(ii))]; ...
                       n2p = [n2 '(' num2str(jj) ').' char(fn2(pnt2(ii)))];
            end
            [fss1, fss2, err] = comp_struct(getfield(s1(jj),char(fn1(pnt1i(ii)))), ...
                                            getfield(s2(jj),char(fn2(pnt2i(ii)))),n1p,n2p,p);
            if ~iscell(err)
                err = cellstr(err); 
            end
            fs1 = [fs1; fss1]; 
            fs2 = [fs2; fss2]; 
            er = [er; err];
        end
    end
elseif isstruct(s1) ~= isstruct(s2)
    % one structure, one not
    er{1} = 'Type mismatch';
    display_cond(sprintf('%s        %s              Type mismatch - NOT equal',n1,n2),mode);    
    fs1 = n1; 
    fs2 = n2; 
    if p; display_cond('Paused .....',mode); pause; end
elseif (isstruct(s1) && isstruct(s2)) && (length(s1) ~= length(s2))
    % both are structures but of different lengths
    er{1} = 'Length mismatch';
    display_cond(sprintf('%s        %s              Length mismatch',n1,n2),mode);
    fs1 = n1; 
    fs2 = n2; 
    if p; display_cond('Paused .....',mode); pause; end
elseif isa(s1,'sym') && isa(s2,'sym')
    % compare two symbolic expresions
    % direct compare
    ss1 = simple(s1); ss2 = simple(s2);
    t = isEqual(simplify(ss1),simplify(ss2));
    if ~t
        % could still be equal, but not able to reduce the symbolic expresions
        % get factors
        f1 = findsym(ss1); f2 = findsym(ss2);
        w = warning; 
        if isEqual(f1,f2)
            % same symbolic variables.  same eqn?
            temp = [1 findstr(f1,' ') + 1]; tres = NaN * zeros(1,30);
            for jj = 1:1e3
                ss1e = ss1; ss2e = ss2;
                for ii = 1:length(temp)
                    tv = (real(rand^rand)) / (real(rand^rand));
                    ss1e = subs(ss1e,f1(temp(ii)),tv);
                    ss2e = subs(ss2e,f2(temp(ii)),tv);
                end

                % check for match
                if isnan(ss1e) || isnan(ss2e)
                    tres(jj) = 1;
                elseif (double(ss1e) - double(ss2e)) < tol
                    tres(jj) = 1;
                end
            end

            % now check symbolic equation results
            if sum(tres) == length(tres)
                % symbolics assumed to be the same equation
                t = 1;
            end
        end
        warning(w)
    end
    if t
        display_cond(sprintf('%s        %s              match',n1,n2),mode)
    else
        display_cond(sprintf('%s        %s              do NOT match',n1,n2),mode)
        fs1 = n1; 
        fs2 = n2; 
        er{1} = 'Symbolic disagreement';
    end
else
    % neither is a structure - compare directly
    if isEqual(s1,s2)
        display_cond(sprintf('%s        %s              match',n1,n2),mode)
    else
        % check for "false" failures
        % check structure size
        if strcmp(num2str(size(s1)),num2str(size(s2)))
            % structures are same size - check for precision error if numbers
            if ischar(s1) || iscell(s1) || ...
                (isnumeric(s1) && isnumeric(s2) && (max(max(max(abs(s1 - s2)))) > tol * (max(max(max([s1 s2]))) ...
                - min(min(min([s1 s2]))))))
            
                % same size, diferent values or not numbers
                display_cond(sprintf('%s        %s              do NOT match',n1,n2),mode)
                fs1 = [fs1; {n1}]; fs2 = [fs2; {n2}]; er = [er; {'?'}];
                if ischar(s1)
                    er1{1} = sprintf('%s is char - %s',n1,char(s1)); display_cond(er1,mode);
                end
                if ischar(s2)
                    er2{1} = sprintf('%s is char - %s',n2,char(s2)); display_cond(er2,mode);
                end
                if exist('er1','var') && exist('er2','var')
                    er = [er; {[er1 ' ---> ' er2]}];
                end
                if ~ischar(s1) && ~iscell(s1)
                    er{1} = sprintf('Max error (%%) = %g%%', ...
                                  max(max(max(abs(s1 - s2)))) / ...
                                  (max(max(max([s1 s2]))) - min(min(min([s1 s2])))));
                    display_cond(er,mode);
                end
                if p
                    display_cond('Paused .....',mode); 
                    pause; 
                end
            else
                % tolerance agreement
                display_cond(sprintf('%s        %s              tolerance match',n1,n2),mode)
            end
        else
            % size difference
            display_cond(sprintf('%s        %s              do NOT match - DIFFERENT SIZES',n1,n2),mode)
            fs1 = [fs1; {n1}]; fs2 = [fs2; {n2}]; er = [er; {'String size error'}];
            if p
                display_cond('Paused .....',mode); 
                pause; 
            end
        end
    end
end

% display non matching fields
if ~isempty(fs1)
    for ii = 1:length(fs1)
        if strcmp(n1,fs1(ii))
            display_cond(sprintf('First Structure non-matched fields:        %s',[n1]),mode)
        end
        if p; display_cond('Paused .....',mode); pause; end
    end
end
if ~isempty(fs2)
    for ii = 1:length(fs2)
        if strcmp(n2,fs2(ii))
            display_cond(sprintf('Second Structure non-matched fields:       %s',[n2]),mode)
        end
        if p; display_cond('Paused .....',mode); pause; end
    end
end



% -------------------------------------------------------------------
function b = isEqual(n1, n2)
b = true;
if isempty(n1) && isempty(n2)
    return 
end
b = isequal(n1, n2);



% -------------------------------------------------------------------
function display_cond(str,mode)
if(mode==1)
    disp(str);
elseif(mode==0)
    return;
end
