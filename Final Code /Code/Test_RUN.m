%contact mail ID - kripalrao12@gmail.com

clc
clear
%% Main Section - Uncomment according to the requirement

info = NacaBuild(struct('number','0112','num_p',300,'HalfCosineSpacing',1));                       % Build NACA 4 from Equations
info2 =NacaBuild(struct('number','2212','num_p',300,'HalfCosineSpacing',1));                   % Build NACA 4 from Equations -For Limits (if required)                                                                                                                                      %
info3 =NacaBuild(struct('number','6412','num_p',300,'HalfCosineSpacing',1));                   % Build NACA 4 from Equations -For Limits (if required)
 p0 = getParsecc(info);                                                                                                        % Get the  PARSEC co-efficients
cst0 = getCST(info);                                                                                                             % Get the  CST co-efficients
cst02 = getCST(info2);                                                                                                         % Get the  CST co-efficients                                                                                                   
cst03 = getCST(info3);                                                                                                         % Get the  CST co-efficients
buildfile('opt4412).DAT',info.x,info.y);                                                                                  % Builts the dat file   (Must be uncommented if xfoil function is  being used)                                  
[R,M] = calc();                                                                                                                       % Get Re and Mach ( Can be edited according to the preferred range)                         
 [result, cd, cl, clcd] = xfoil(R,M);                                                                                        % Get cl, cd, L/D from Xfoil  for info (airfoil)                         
  %foilc = CSTForFitBuild(info.x,cst0,5,0.5,0.5);                                                                     % Get CST Coefficients for info(Airfoil)               
%foil = ParsecForFitBuild(info.x,p0);                                                                                    % verification of the PARRSEC Coefficients - by bacl sustitution
%plot(info.x,foilc)               

%ohio = 0; % if PARSEC optimisation - 1 , CST - 0 
%  [Result_optcd, foil2, cd] = GA_optcd(ohio,info.x,p0,cst0,cst02,cst03);                             %For obtaining optimum cd airfoil


%Save the 1stoptimum cd file
%buildfile('optcd1.DAT',info.x,foil2(:,1));
%Save the 2nd optimum cd file
%buildfile('optcd2.DAT',info.x,foil2(:,2));

% [Result_optcl, foil3, cl] = GA_optcl(ohio,info.x,p0,cst0,cst02);
% %For obtaining optimum cd airfoil, using csts as limits

%  buildfile('optcl1.DAT',info.x,foil3(:,1));
%  buildfile('optcl2.DAT',info.x,foil3(:,2));

%  [Result_optclcd, foil4, clcd] =
%  GA_optclcd(ohio,info.x,p0,cst0,cst02,cst03)                    
%For obtaining optimum cl/cd airfoil, using csts as limits

%% Get the airfoil

function info = NacaBuild(naca_details)

num = naca_details.number;
thickness = str2double(num(3:4))/100;
max_c = str2double(num(1))/100;
x_cord_maxc = str2double(num(2))/10;

%coefficients - from  THEORY OF WING SECTIONS-CHAP-FAMILIES OF WING SECTIONS - pg 113

a0 = 0.29690;
a1 = -0.12600;
a2 = -0.35160;
a3 = 0.28430;
a4 = -0.1036;

if naca_details.HalfCosineSpacing==1
    beta = linspace(0,pi,naca_details.num_p+1)';
    x = (0.5*(1-cos(beta))); % Half cosine based spacing
    info.header = ['NACA ' naca_details.number ' [' num2str(naca_details.num_p) 'panels, half cosine x-spacing]'];  
else
    x = linspace(0,1,naca_details.num_p+1)';
    info.header = ['NACA ' naca_details.number ' [' num2str(naca_details.num_p) 'panels, uniform x-spacing]'];  
end

%getting camber x-co
xc1=x((x<=x_cord_maxc));
xc2=x((x>x_cord_maxc));

% Obtaining thickness distribution
yt=(thickness/0.20)*(a0*sqrt(x)+a1*x+a2*x.^2+a3*x.^3+a4*x.^4);

%obtaining the mean line- from  THEORY OF WING SECTIONS-CHAP-FAMILIES OF
%WING SECTIONS - pg 114

    yc1=(max_c/x_cord_maxc^2)*(2*x_cord_maxc*xc1-xc1.^2);                         % forward of maximum ordinate 
    yc2=(max_c/(1-x_cord_maxc)^2)*((1-2*x_cord_maxc)+2*x_cord_maxc*xc2-xc2.^2);   % aft of maximum ordinate
    yc=[yc1 ; yc2];

%slopes of the mean line

    dyc1_dx=(max_c/x_cord_maxc^2)*(2*x_cord_maxc-2*xc1);
    dyc2_dx=(max_c/(1-x_cord_maxc)^2)*(2*x_cord_maxc-2*xc2);
    dyc_dx=[dyc1_dx ; dyc2_dx];
    theta=atan(dyc_dx);                                       

%Upper Curve
    xu=x-yt.*sin(theta);
    yu=yc+yt.*cos(theta);

%Lower Curve
    xl=x+yt.*sin(theta);
    yl=yc-yt.*cos(theta);

    info.x = [flipud(xu);xl(2:end)];
    info.y = [flipud(yu);yl(2:end)];
xc=[xc1 ; xc2];


% Plot
figure("Name",num)
hold on
 plot(info.x,info.y,'black');
 plot(xc,yc,'red');
 plot(x,yt,'red--');
 legend("Aifoil","Mean Camber","Thickness Distribution");
grid on;
xlim([0,1]);
ylim([-0.25,0.25]);
hold off

info.x(1) = 1;
info.x(1) = 1;


end

%% Get PARSEC coefficients
function para = getParsecc(info)

[~,i] = min(info.x);
[maxy,j] = max(info.y);
x_maxy = info.x(j);
[miny,k] = min(info.y);
x_miny = info.x(k);
te_t = info.y(1)-info.y(end);
y_te = (info.y(1)+info.y(end))/2;

x_up = info.x(i);
x_up1 = info.x(i-1);
x_up2 = info.x(i-2);
y_up = info.y(i);
y_up1 = info.y(i-1);
y_up2 = info.y(i-2);

    rUp = (sqrt((x_up-x_up1)^2+(y_up-y_up1)^2)* ...
        sqrt((x_up-x_up2)^2+(y_up-y_up2)^2)* ...
        sqrt((x_up2-x_up1)^2+(y_up2-y_up1)^2))/...
        (abs(x_up*(y_up1-y_up2)+x_up1*(y_up2-y_up)+x_up2*(y_up-y_up1))*2);  % Circumradius of a traingle

x_low = info.x(i+1);
x_low1 = info.x(i+2);
x_low2 = info.x(i+3);
y_low = info.y(i+1);
y_low1 = info.y(i+2);
y_low2 = info.y(i+3);

   rlow = (sqrt((x_low-x_low1)^2+(y_low-y_low1)^2)* ...
    sqrt((x_low-x_low2)^2+(y_low-y_low2)^2)* ...
    sqrt((x_low2-x_low1)^2+(y_low2-y_low1)^2))/...
    (abs(x_low*(y_low1-y_low2)+x_low1*(y_low2-y_low)+x_low2*(y_low-y_low1))*2);  

    beta = atan2(abs(det([[info.x(2)     info.y(2)    ] - [info.x(1)   info.y(1)  ];...
        [info.x(end-1) info.y(end-1)] - [info.x(end) info.y(end)]])),...
        dot([info.x(2)     info.y(2)]     -[info.x(1) info.y(1)    ],...
        [info.x(end-1) info.y(end-1)] -[info.x(end) info.y(end)]))*180/pi;               %Sharpness of a curve

       % alpha
    xx(1) = (info.x(2)+info.x(end-1))/2;
    xx(2) = (info.x(1)+info.x(end))/2;
    xx(3) = xx(1);
    yy(1) = (info.y(2)+info.y(end-1))/2;
    yy(2) = (info.y(1)+info.y(end))/2;
    yy(3) = xx(2);
    alpha = atan2(abs(det([[xx(1) yy(1)] - [xx(2) yy(2)];...
        [xx(3) yy(3)] - [xx(2) yy(2)]])),...
        dot([xx(1) yy(1)] -[xx(2) yy(2)],...
        [xx(3) yy(3)] -[xx(2) yy(2)]));

      % Slope at Max and Min

    sUp  = polyfit(info.x(j-1:j+1),...
        info.y(j-1:j+1),2);
    sLow = polyfit(info.x(k-1:k+1),...
        info.y(k-1:k+1),2);
    slopeUp = 2*sUp(1);
    % derived at min
    slopeLow = 2*sLow(1);

    p = [rUp rlow x_maxy maxy slopeUp x_miny miny slopeLow te_t y_te alpha beta];

    Fun2Min = @(p)(ParsecForFitBuild(info.x,p)-info.y);

multiProblem = MultiStart;
nTries =1;
%lb =[0    0 -Inf -Inf -Inf -Inf -Inf -Inf    0    0    0    0];
%ub = [];
options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective','TolFun',1e-6,...      %algo = levenberg-marquardt/trust-region-reflective
                 'MaxFunEvals',1200,'MaxIter',400,'DiffMinChange',...
                 0,'DiffMaxChange',Inf,'TypicalX',[0.01 0.01 0.1 0.1 0.1 0.1 0.1 0.1 0.01 0.01 2 2]);
problem  = createOptimProblem('lsqnonlin','x0',p,'objective',Fun2Min,'options',options);
[para,other.fmin,other.flag,other.output,other.prop] = run(multiProblem,problem,nTries);
foil = ParsecForFitBuild(info.x,para);
display(other.fmin)


figure(420)
hold on
plot(info.x,foil,'red');
plot(info.x,info.y,'black');
legend("PARSEC","Actual");
grid on
xlim([0,1]);
ylim([-0.3,0.3]);
hold off
end

%% Get weights of CST
function weights = getCST(info)


wu_g = [0.1 0.1 0.1 0.1];
wl_g = [-0.1, -0.1, -0.1, -0.1];
dz_g = 0;
p0 = [wu_g wl_g dz_g];
flw = length(wu_g)+1;
nTries =1;
%%% LEAST SQUARES SEARCH 
Fun2Min = @(w)abs(CSTForFitBuild(info.x,w,flw,0.5,1)-info.y);
multiProblem = MultiStart;
options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective','TolFun',1e-6,...      %algo = levenberg-marquardt/trust-region-reflective
                 'MaxFunEvals',1200,'MaxIter',400,'DiffMinChange',...
                 0,'DiffMaxChange',Inf);
problem  = createOptimProblem('lsqnonlin','x0',p0,'objective',Fun2Min,'options',options);
[weights,other.fmin,other.flag,other.output,other.prop] = run(multiProblem,problem,nTries);
display(other.fmin)
foil = CSTForFitBuild(info.x,weights,5,0.5,1);
figure("Name",info.header)
hold on
plot(info.x,foil,'red');
plot(info.x,info.y,'black');
legend("CST","Actual")
grid on
xlim([0,1]);
ylim([-0.3,0.3]);
hold off
end

%% Build Airfoil using cst weights

function zout = CSTForFitBuild(x,w,flw,N1,N2)

% Description : Create a set of airfoil coordinates using CST parametrization method 
% x: coordinates
% w: upper and lower weights
%    NOTE: the last weight must be the t.e. thickness
% flw: parameter that indicates the position of the first lower weight

wu = w(1:flw-1);
wl = w(flw:end-1);
dz = w(end)/2; 

% N1 and N2 parameters (N1 = 0.5 and N2 = 1 for airfoil shape)
%N1 = 0.5;
%N2 = 1;

% Separation of upper and lower surfaces
[ ~ , zerind ] = min(x(:,1));
xu= x(1:zerind-1); % Lower surface x-coordinates
xl = x(zerind:end); % Upper surface x-coordinates

[yl] = ClassShape(wl,xl,N1,N2,-dz); % Call ClassShape function to determine lower surface y-coordinates
[yu] = ClassShape(wu,xu,N1,N2,dz);  % Call ClassShape function to determine upper surface y-coordinates

y = [yu;yl]; % Combine upper and lower y coordinates

% forcing the t.e. thickness to be 0 (in case of dz=0) in order to avoid numerical errors 
if (x(1) == 1 && (y(1)-y(end))<0 && dz >= 0)
    y(1) = 0;
    y(end) = 0;
end

zout = y;


%% Function to calculate class and shape function
function [y] = ClassShape(w,x,N1,N2,dz)

% Class function; taking input of N1 and N2
for i = 1:size(x,1)
    C(i,1) = x(i)^N1*((1-x(i))^N2);                                         %#ok<AGROW> 
end

% Shape function; using Bernstein Polynomials
n = size(w,2)-1; % Order of Bernstein polynomials

for i = 1:n+1
     K(i) = factorial(n)/(factorial(i-1)*(factorial((n)-(i-1))));           %#ok<AGROW> 
end

for i = 1:size(x,1)
    S(i,1) = 0;                                                             %#ok<AGROW> 
    for j = 1:n+1
        S(i,1) = S(i,1) + w(j)*K(j)*x(i)^(j-1)*((1-x(i))^(n-(j-1)));
    end
end

% Calculate y output
for i = 1:size(x,1)
   y(i,1) = C(i,1)*S(i,1) + x(i)*dz;                                        %#ok<AGROW> 
end
end
end

%% Get foil from PARSEC coefficients
function foil = ParsecForFitBuild(x,p)
%display(p);
[~, locc] = min(x);
xUp=x(1:locc);
xLow=x(locc+1:end);

Foil =   @(x,aa) aa(1)*x.^(1/2)           + aa(2)*x.^(3/2) + aa(3)*x.^(5/2) + ...
    aa(4)*x.^(7/2)  + aa(5)*x.^(9/2)     + aa(6)*x.^(11/2);

% Define matricies
c1 = [1, 1, 1,...
    1, 1, 1];

c2 = [p(3)^(1/2),  p(3)^(3/2), p(3)^(5/2),...
    p(3)^(7/2),  p(3)^(9/2), p(3)^(11/2)];

c3 = [1/2,  3/2,  5/2,...
    7/2,  9/2,  11/2];

c4 = [(1/2)*p(3)^(-1/2),  (3/2)*p(3)^(1/2),  (5/2)*p(3)^(3/2),...
    (7/2)*p(3)^(5/2),    (9/2)*p(3)^(7/2),  (11/2)*p(3)^(9/2)];

% c5 = [(-1/4)*p(3)^(-3/2), (3/4)*p(3)^(-1/2), (15/4)*p(3)^(1/2),...
%      (35/4)*p(3)^(3/2),   (53/4)*p(3)^(5/2), (99/4)*p(3)^(7/2)];
c5 = [(-1/4)*p(3)^(-3/2), (3/4)*p(3)^(-1/2), (15/4)*p(3)^(1/2),...
    (35/4)*p(3)^(3/2),   (63/4)*p(3)^(5/2), (99/4)*p(3)^(7/2)];

c6 = [1, 0, 0,...
    0, 0, 0];

Cup=[c1; c2; c3; c4; c5; c6];
bup=[p(10)+p(9)/2;p(4);  tand(-p(11)-p(12)/2); 0; p(5); (sqrt(2*p(1)))];
aup    = linsolve(Cup, bup);
foilUp = real(Foil(xUp,aup));

c7  = [1, 1, 1,...
    1, 1, 1];

c8  = [p(6)^(1/2),  p(6)^(3/2),  p(6)^(5/2),...
    p(6)^(7/2),  p(6)^(9/2), p(6)^(11/2)];

c9  = [1/2,  3/2,  5/2,...
    7/2,  9/2,  11/2];

c10 = [(1/2)*p(6)^(-1/2),  (3/2)*p(6)^(1/2), (5/2)*p(6)^(3/2),...
    (7/2)*p(6)^(5/2),   (9/2)*p(6)^(7/2), (11/2)*p(6)^(9/2)];

c11 = [(-1/4)*p(6)^(-3/2), (3/4)*p(6)^(-1/2), (15/4)*p(6)^(1/2),...
    (35/4)*p(6)^(3/2),  (63/4)*p(6)^(5/2), (99/4)*p(6)^(7/2)];

c12 = [1, 0, 0,...
    0, 0, 0];

Clo=[c7; c8; c9; c10; c11; c12];
blo=[p(10)-p(9)/2;p(7);  tand(-p(11)+p(12)/2); 0; p(8); -(sqrt(2*p(2)))];
alower = linsolve(Clo, blo);
foilLow = real(Foil(xLow,alower));

foil = [foilUp; foilLow];
end

   %% Get Reynolds number and Mach No
   function [R,M] = calc()
   height = 10972.8;
   [~, a, ~, rho] = atmosisa(height);
   visc = 1.825*10^-5;
   l = 1;
   M = linspace(0.3,0.7,9);
   vel = a*M;
   R = (rho*vel*l)/visc;
   end
  
   %% Run Xfoil
   function [result, cd, cl, clcd] = xfoil(R,M)
for i= 1:numel(M')
   % d=round(i,1);
   % display(d);
  fid = fopen("input.dat", 'wt'); 
fprintf(fid,['LOAD opt4412).DAT \n ' ...
    'PANE\n']); 
 fprintf(fid, 'PLOP\nG\n\n');                                               % Supress Plotting
fprintf(fid,'OPER \n'); 
fprintf(fid,'VISC 1.825E-05 \n'); 
fprintf(fid,'Mach %0.4f \n',M(i));
fprintf(fid,'Re %0.4f \n',R(i));
fprintf(fid,'ITER 1500 \n');
fprintf(fid,'pacc \n\n\n'); 
fprintf(fid,'AseQ\n 0\n 5\n 0.5\n');
fprintf(fid,'dump\n output(%0.1f).dat\n',i);
fprintf(fid,'cpwr xvscp(%0.1f).dat\n',i);
fprintf(fid,'pwrt\nPolarP.dat\n');
    fprintf(fid,'plis\n');
    fprintf(fid,'\nquit\n'); 
fclose(fid);

%- create the run file (.bat): -----------------------
fid = fopen("run.bat", 'wt'); 
comand = '@echo off & xfoil < input.dat > outputfile.dat'; 
fprintf(fid,'%s\n',comand); 
fclose(fid); 
%- Execute the run file ------------------------------
filepath = mfilename("fullpath");                                                % Get the airfoil
[filepath,~] = fileparts(filepath);
% system('cd C:\MY PC\MIT\ICCMEH CFD\CODE_to be built\');                        % old code
filepath = append('cd ',filepath);
system(filepath);
system('run.bat');

source = sprintf('output(%0.1f).dat',i);
movefile(source,'Results\Output\')
source = sprintf('xvscp(%0.1f).dat',i);
movefile(source,'Results\xvscp\');
source = sprintf('PolarP.dat');
movefile(source,'Results\PolarP\PolarP.dat');



Polar_data = readmatrix("Results\PolarP\PolarP.dat");                   %1-ALpfa 2-cl 3-cd 4-cdp 5-cm 6-top_xtr 7-bot_xtr

Polar_data(isnan(Polar_data)) = 0;

%if Polar_data

i = round(i);                                                                %#ok<FXSET> % change this if the number of divisions for the lopp iter has been increased
switch(i)                                                                         
    case 1
    result.mach0_3 = Polar_data(:,[1,2,3]);
    case 2
    result.mach0_35 = Polar_data(:,[1,2,3]);
    case 3
    result.mach0_4 = Polar_data(:,[1,2,3]);
    case 4
    result.mach0_45 = Polar_data(:,[1,2,3]);
    case 5
    result.mach0_5 = Polar_data(:,[1,2,3]);
    case 6
    result.mach0_55 = Polar_data(:,[1,2,3]);
    case 7
    result.mach0_6 = Polar_data(:,[1,2,3]);
    case 8
    result.mach0_65 = Polar_data(:,[1,2,3]);    
    case 9
    result.mach0_7 = Polar_data(:,[1,2,3]);
end
end
cl = (mean(result.mach0_3(:,2))+mean(result.mach0_35(:,2))+mean(result.mach0_4(:,2))+mean(result.mach0_45(:,2))+mean(result.mach0_5(:,2))+mean(result.mach0_55(:,2))+mean(result.mach0_6(:,2))+mean(result.mach0_65(:,2))+mean(result.mach0_7(:,2)))/9;%+mean(result.mach0_8(:,2)));
cd = (mean(result.mach0_3(:,3))+mean(result.mach0_35(:,3))+mean(result.mach0_4(:,3))+mean(result.mach0_45(:,3))+mean(result.mach0_5(:,3))+mean(result.mach0_55(:,3))+mean(result.mach0_6(:,3))+mean(result.mach0_65(:,3))+mean(result.mach0_7(:,3)))/9;%+mean(result.mach0_8(:,3)));     
%clmin = mink([result.mach0_3(:,2)' result.mach0_4(:,2)' result.mach0_5(:,2)' result.mach0_6(:,2)' result.mach0_7(:,2)' ],1);  %add result.mach0_8(:,2)'    
clcd = cl/cd;
   end

%% This function optimizes an airfoil shape based on the coeffecient of drag
function [Result_optcd, foil2,cdfittest2] = GA_optcd(ohio,x,p0,cst0,cst02,cst03)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%value
%genNo      number of generations to mate
%p0         Original airfoil to oprimize
%range      Randomizer range to vary the PARSEC parameters
%uinf       flow free stream velocity
%AOA        airfoil angle of attack
%Npanel     number of panels for the fitness function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%genetic parameters
[R,M] = calc();
genNo=50;
range=[0.0015 0.0015 0.025 0.015 -0.01 0.002 -0.0015 0.0075 0.001 0.001 -0.0175 0.005];

if ohio ==1
foil2 = ParsecForFitBuild(x,p0); 
else
foil2 = CSTForFitBuild(x,cst0,5,0.5,1);
end

buildfile('opt4412).DAT',x,foil2)
 [~, cdoriginal, ~, ~] = xfoil(R,M);

%[cloriginal,~]=solver(p0);
popsize=30;  %population size
transprob=0.15;  %transcendence percentage 
crossprob=0.75;    %cross over percentage
mutprob=0.3;       %mutation percentage
newpop=[];

if ohio == 1

        for k=1:genNo
            q= k-1;
            u = ['Current Generation ',num2str(q),' of 30 mutated and cross-overed values (cd) :) -PARSEC boi'];
            disp(u);
            cd=[];
            p=[];

        %population evaluation (starting from the second generation) 
        for i=1:length(newpop)
             u = 'Pop is evaluating  Gen values;)';
            disp(u);
            p1=newpop(i,:);
            foil = ParsecForFitBuild(x,p1); 
            buildfile('opt4412).DAT',x,foil)
            [~,cdnew, ~, ~] = xfoil(R,M);  %fitness evaluation
            cd = [cd;cdnew];                                                         %#ok<AGROW> 
            p = [p;p1];                                                              %#ok<AGROW> 
        end

        %first population initialization
        for i=1:popsize-length(newpop)
            o = popsize-i;
             u = ['pop is yet to initialize ',num2str(o),' values - first Gen :/'];
            disp(u);
            p1=randp(p0,range);
            foil = ParsecForFitBuild(x,p1); 
            buildfile('opt4412).DAT',x,foil)
            [~, cdnew, ~, ~] = xfoil(R,M);    %fitness evaluation
            cd=[cd;cdnew];                                                           %#ok<AGROW> 
            p=[p;p1];                                                                %#ok<AGROW> 
        end
        pop=p;
        %constraining the coeffecient of lift
        for i=1:length(cd)
        if cd(i)>=cdoriginal
                cd(i)=cdoriginal;                                                    %#ok<AGROW> 
        end
        end
        %sorting the individuals by the fittest
        fi=cd./sum(cd);
        [fittest,ind] = sort(fi,'ascend');
        fittest = fittest(1:ceil(transprob*popsize));                                %#ok<NASGU> 
        ind = ind(1:ceil(transprob*popsize));
        
        if k~=genNo
            newpop = pop(ind,:);
            %crossover
            for i=1:ceil(crossprob*popsize)
                indv1=randi([1,popsize],1);
                indv2=randi([1,popsize],1);
                crossindex=randi([1,12],1);
               newpop=[newpop;pop(indv1,1:crossindex) pop(indv2,crossindex+1:end)]; %#ok<AGROW> 
            end
            %mutation
            for i=1:ceil(mutprob*popsize)
                indv=pop(randi([1,popsize],1),:);
                mutindex=randi([1,11],1);
                pmut=randp(p0,range);
                indv(mutindex)=pmut(mutindex);
                newpop=[newpop;indv];                                               %#ok<AGROW> 
            end
        end
        end
        %choosing the tournemnt winner or the most evolved individual
        fittest = pop(ind(1),:);
        cdfittest=cd(ind(1));
        if cdfittest==cdoriginal
            fittest = p0;
        end
else 
    range  = [cst02(1) cst03(1) cst02(2) cst03(2) cst02(3) cst03(3) cst02(4) cst03(4) cst02(5) cst03(5) cst02(6) cst03(6) cst02(7) cst03(7) cst02(8) cst03(8) cst02(9) cst03(9)];     
    for k=1:genNo
            q= k-1;
            u = ['Current Generation ',num2str(q),' of 30 mutated and cross-overed values (cd) :) -CST boi'];
            disp(u);
        cd=[];
        cst=[];

        %population evaluation (starting from the second generation)
        
        
        for i=1:length(newpop)
             u = 'Pop is evaluating  Gen values;)';
            disp(u);
            cst1=newpop(i,:);
            foil = CSTForFitBuild(x,cst1,5,0.5,1);                             % Change N1, N2 if needed 
            buildfile('opt4412).DAT',x,foil)
            [~,cdnew, ~, ~] = xfoil(R,M);  %fitness evaluation
            cd = [cd;cdnew];                                                         %#ok<AGROW> 
            cst = [cst;cst1];                                                              %#ok<AGROW> 
        end
        %first population initialization
        for i=1:popsize-length(newpop)
            o = popsize-i;
             u = ['pop is yet to initialize ',num2str(o),' values - first Gen :/'];
            disp(u);
            cst1 = randcst(cst0,range);
            foil = CSTForFitBuild(x,cst1,5,0.5,1); 
            buildfile('opt4412).DAT',x,foil);
            [~, cdnew, ~, ~] = xfoil(R,M);    %fitness evaluation
            cd = [cd;cdnew];                                                           %#ok<AGROW> 
            cst = [cst;cst1];                                                                %#ok<AGROW> 
        end
        pop=cst;
        %constraining the coeffecient of lift
        for i=1:length(cd)
        if cd(i)>=cdoriginal
                cd(i)=cdoriginal;                                                    %#ok<AGROW> 
        end
        end
        %sorting the individuals by the fittest
        fi=cd./sum(cd);
        [fittest,ind] = sort(fi,'ascend');
        fittest = fittest(1:ceil(transprob*popsize));                                %#ok<NASGU> 
        ind = ind(1:ceil(transprob*popsize));
        
        if k~=genNo
            newpop = pop(ind,:);
            %crossover
            for i=1:ceil(crossprob*popsize)
                indv1=randi([1,popsize],1);
                indv2=randi([1,popsize],1);
                crossindex=randi([1,9],1);
               newpop=[newpop;pop(indv1,1:crossindex) pop(indv2,crossindex+1:end)]; %#ok<AGROW> 
            end
            %mutation
            for i=1:ceil(mutprob*popsize)
                indv=pop(randi([1,popsize],1),:);
                mutindex=randi([1,9],1);
                pmut=randcst(cst0,range);
                indv(mutindex)=pmut(mutindex);
                newpop=[newpop;indv];                                               %#ok<AGROW> 
            end
        end
        end
        %choosing the tournemnt winner or the most evolved individual
        fittest = pop(ind(1),:);
        cdfittest=cd(ind(1));
        if cdfittest==cdoriginal
            fittest = cst0;
        end

    
end
if ohio == 1
    fittest2 = pop(ind(2),:);
    cdfittest2 = cd(ind(2));
    Result_optcd = vertcat(fittest,fittest2);
    foil2(:,1) = ParsecForFitBuild(x,Result_optcd(1,:));
    foil2(:,2) = ParsecForFitBuild(x,Result_optcd(2,:));
else
    fittest2 = pop(ind(2),:);
    cdfittest2 = cd(ind(2));
    Result_optcd = vertcat(fittest,fittest2);
    foil2(:,1) = CSTForFitBuild(x,Result_optcd(1,:),5,0.5,1);
    foil2(:,2) = CSTForFitBuild(x,Result_optcd(2,:),5,0.5,1);
end
end

%% This function optimizes an airfoil shape based on the coeffecient of lift
function [Result_optcl, foil3, clfittest2] = GA_optcl(ohio,x,p0,cst0,cst02)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%value
%genNo      number of generations to mate
%p0         Original airfoil to oprimize
%range      Randomizer range to vary the PARSEC parameters
%uinf       flow free stream velocity
%AOA        airfoil angle of attack
%Npanel     number of panels for the fitness function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%genetic parameters
[R,M] = calc();
if ohio == 1
genNo=25;
range=[0.0015 0.0015 0.025 0.015 -0.01 0.02 -0.015 0.075 0 0 -0.175 0.05];

foil2 = ParsecForFitBuild(x,p0); 
buildfile('opt4412).DAT',x,foil2)
 [~, ~, cloriginal, ~] = xfoil(R,M);

%[cloriginal,~]=solver(p0);
popsize=30;  %population size
transprob=0.05;  %transcendence percentage 
crossprob=0.75;    %cross over percentage
mutprob=0.2;       %mutation percentage
newpop=[];
for k=1:genNo
    q= k-1;
    u = ['Current Generation ',num2str(q),' of 30 mutated and cross-overed values (cl) :)'];
    disp(u);
cl=[];
p=[];
%population evaluation (starting from the second generation)
for i=1:length(newpop)
     u = 'Pop is evaluating  Gen values;)';
    disp(u);
    p1=newpop(i,:);
    foil = ParsecForFitBuild(x,p1); 
    buildfile('opt4412).DAT',x,foil)
    [~, ~, clnew, ~] = xfoil(R,M);  %fitness evaluation
    cl=[cl;clnew];                                                          %#ok<AGROW> 
    p=[p;p1];                                                               %#ok<AGROW> 
end
%first population initialization
for i=1:popsize-length(newpop)
    o = popsize-i;
     u = ['pop is yet to initialize ',num2str(o),' values - first Gen :/'];
    disp(u);
    p1=randp(p0,range);
    foil = ParsecForFitBuild(x,p1); 
    buildfile('opt4412).DAT',x,foil)
    [~, ~, clnew, ~] = xfoil(R,M);   
    cl=[cl;clnew];                                                          %#ok<AGROW> 
    p=[p;p1];                                                               %#ok<AGROW> 
end
pop=p;
%constraining the coeffecient of lift
for i=1:length(cl)
if cl(i)<=cloriginal
        cl(i)=cloriginal;                                                   %#ok<AGROW> 
end
end
%sorting the individuals by the fittest
fi=cl./sum(cl);
[fittest,ind]=sort(fi,'descend');
fittest=fittest(1:ceil(transprob*popsize));                                 %#ok<NASGU> 
ind=ind(1:ceil(transprob*popsize));
if k~=genNo
    newpop = pop(ind,:);
    %crossover
    for i=1:ceil(crossprob*popsize)
        indv1=randi([1,popsize],1);
        indv2=randi([1,popsize],1);
        crossindex=randi([1,12],1);
       newpop=[newpop;pop(indv1,1:crossindex) pop(indv2,crossindex+1:end)]; %#ok<AGROW> 
    end
    %mutation
    for i=1:ceil(mutprob*popsize)
        indv=pop(randi([1,popsize],1),:);
        mutindex=randi([1,11],1);
        pmut=randp(p0,range);
        indv(mutindex)=pmut(mutindex);
        newpop=[newpop;indv];                                               %#ok<AGROW> 
    end
end
end
%choosing the tournemnt winner or the most evolved individual
fittest = pop(ind(1),:);
clfittest=cl(ind(1));
if clfittest==cloriginal
    fittest = p0;
end
else
      range  = [cst0(1) cst02(1) cst0(2) cst02(2) cst0(3) cst02(3) cst0(4) cst02(4) cst0(5) cst02(5) cst0(6) cst02(6) cst0(7) cst02(7) cst0(8) cst02(8) cst0(9) cst02(9)];     
      genNo=25;
      foil2 = CSTForFitBuild(x,cst0,5,0.5,1); 
      buildfile('opt4412).DAT',x,foil2)
      [~, ~, cloriginal, ~] = xfoil(R,M);
    
      %[cloriginal,~]=solver(p0);
      popsize=30;  %population size
      transprob=0.05;  %transcendence percentage 
      crossprob=0.75;    %cross over percentage
      mutprob=0.2;       %mutation percentage
      newpop=[];
      for k=1:genNo
            q= k-1;
            u = ['Current Generation ',num2str(q),' of 30 mutated and cross-overed values (cd) :) -CST boi'];
            disp(u);
        cl=[];
        cst=[];

        %population evaluation (starting from the second generation)
        
        
        for i=1:length(newpop)
             u = 'Pop is evaluating  Gen values;)';
            disp(u);
            cst1=newpop(i,:);
            foil = CSTForFitBuild(x,cst1,5,0.5,1);                             % Change N1, N2 if needed 
            buildfile('opt4412).DAT',x,foil)
            [~,cdnew, ~, ~] = xfoil(R,M);  %fitness evaluation
            cl = [cl;cdnew];                                                         %#ok<AGROW> 
            cst = [cst;cst1];                                                              %#ok<AGROW> 
        end
        %first population initialization
        for i=1:popsize-length(newpop)
            o = popsize-i;
             u = ['pop is yet to initialize ',num2str(o),' values - first Gen :/'];
            disp(u);
            cst1 = randcst(cst0,range);
            foil = CSTForFitBuild(x,cst1,5,0.5,1); 
            buildfile('opt4412).DAT',x,foil);
            [~, clnew, ~, ~] = xfoil(R,M);    %fitness evaluation
        %      %geometric constrain
        %     if maxThickness>0.1 
        %         clnew=cloriginal;
        %     elseif maxThickness<0.01  
        %         clnew=cloriginal;
        %     end
            cl = [cl;clnew];                                                           %#ok<AGROW> 
            cst = [cst;cst1];                                                                %#ok<AGROW> 
        end
        pop=cst;
        %constraining the coeffecient of lift
        for i=1:length(cl)
        if cl(i)<=cloriginal
                cl(i)=cloriginal;                                                    %#ok<AGROW> 
        end
        end
        %sorting the individuals by the fittest
        fi=cl./sum(cl);
        [fittest,ind] = sort(fi,'descend');
        fittest = fittest(1:ceil(transprob*popsize));                                %#ok<NASGU> 
        ind = ind(1:ceil(transprob*popsize));
        
        if k~=genNo
            newpop = pop(ind,:);
            %crossover
            for i=1:ceil(crossprob*popsize)
                indv1=randi([1,popsize],1);
                indv2=randi([1,popsize],1);
                crossindex=randi([1,9],1);
               newpop=[newpop;pop(indv1,1:crossindex) pop(indv2,crossindex+1:end)]; %#ok<AGROW> 
            end
            %mutation
            for i=1:ceil(mutprob*popsize)
                indv=pop(randi([1,popsize],1),:);
                mutindex=randi([1,9],1);
                pmut=randcst(cst0,range);
                indv(mutindex)=pmut(mutindex);
                newpop=[newpop;indv];                                               %#ok<AGROW> 
            end
        end
        end
        %choosing the tournemnt winner or the most evolved individual
        fittest = pop(ind(1),:);
        clfittest=cl(ind(1));
        if clfittest==cloriginal
            fittest = cst0;
        end
  
end
if ohio == 1
    fittest2 = pop(ind(2),:);
    clfittest2 = cl(ind(2));
    Result_optcl = vertcat(fittest,fittest2);
    foil2(:,1) = ParsecForFitBuild(x,Result_optcl(1,:));
    foil2(:,2) = ParsecForFitBuild(x,Result_optcl(2,:));
else
    fittest2 = pop(ind(2),:);
    clfittest2 = cl(ind(2));
    Result_optcl = vertcat(fittest,fittest2);
    foil2(:,1) = CSTForFitBuild(x,Result_optcl(1,:),5,0.5,1);
    foil2(:,2) = CSTForFitBuild(x,Result_optcl(2,:),5,0.5,1);
end
end

%% This function optimizes an airfoil shape based on the cl/cd
function [Result_optclcd, foil4, clcd] = GA_optclcd(ohio,x,p0,cst0,cst02,cst03)

%%genetic parameters
[R,M] = calc();
genNo=60;
range=[0.0015 0.0015 0.025 0.015 -0.01 0.002 -0.0015 0.0075 0.001 0.001 -0.0175 0.005];

if ohio ==1
foil2 = ParsecForFitBuild(x,p0); 
else
foil2 = CSTForFitBuild(x,cst0,5,0.5,1);
end

buildfile('opt4412).DAT',x,foil2)
 [~, ~, ~, clcdoriginal] = xfoil(R,M);

%[cloriginal,~]=solver(p0);
popsize=30;  %population size
transprob=0.05;  %transcendence percentage 
crossprob=0.75;    %cross over percentage
mutprob=0.2;       %mutation percentage
newpop=[];

if ohio == 1

        for k=1:genNo
            q= k-1;
            u = ['Current Generation ',num2str(q),' of 30 mutated and cross-overed values (cd) :) -PARSEC boi'];
            disp(u);
            clcd=[];
            p=[];

        %population evaluation (starting from the second generation) 
        for i=1:length(newpop)
             u = 'Pop is evaluating  Gen values;)';
            disp(u);
            p1=newpop(i,:);
            foil = ParsecForFitBuild(x,p1); 
            buildfile('opt4412).DAT',x,foil)
            [~,~, ~, clcdnew] = xfoil(R,M);  %fitness evaluation
            clcd = [clcd;clcdnew];                                                         %#ok<AGROW> 
            p = [p;p1];                                                              %#ok<AGROW> 
        end

        %first population initialization
        for i=1:popsize-length(newpop)
            o = popsize-i;
             u = ['pop is yet to initialize ',num2str(o),' values - first Gen :/'];
            disp(u);
            p1=randp(p0,range);
            foil = ParsecForFitBuild(x,p1); 
            buildfile('opt4412).DAT',x,foil)
            [~, ~, ~, clcdnew] = xfoil(R,M);    %fitness evaluation
        %      %geometric constrain
        %     if maxThickness>0.1 
        %         clnew=cloriginal;
        %     elseif maxThickness<0.01  
        %         clnew=cloriginal;
        %     end
            clcd=[clcd;clcdnew];                                                           %#ok<AGROW> 
            p=[p;p1];                                                                %#ok<AGROW> 
        end
        pop=p;
        %constraining the coeffecient of lift
        for i=1:length(clcd)
        if clcd(i)<=clcdoriginal
                clcd(i)=clcdoriginal;                                                    %#ok<AGROW> 
        end
        end
        %sorting the individuals by the fittest
        fi=clcd./sum(clcd);
        [fittest,ind] = sort(fi,'descend');
        fittest = fittest(1:ceil(transprob*popsize));                                %#ok<NASGU> 
        ind = ind(1:ceil(transprob*popsize));
        
        if k~=genNo
            newpop = pop(ind,:);
            %crossover
            for i=1:ceil(crossprob*popsize)
                indv1=randi([1,popsize],1);
                indv2=randi([1,popsize],1);
                crossindex=randi([1,12],1);
               newpop=[newpop;pop(indv1,1:crossindex) pop(indv2,crossindex+1:end)]; %#ok<AGROW> 
            end
            %mutation
            for i=1:ceil(mutprob*popsize)
                indv=pop(randi([1,popsize],1),:);
                mutindex=randi([1,11],1);
                pmut=randp(p0,range);
                indv(mutindex)=pmut(mutindex);
                newpop=[newpop;indv];                                               %#ok<AGROW> 
            end
        end
        end
        %choosing the tournemnt winner or the most evolved individual
        fittest = pop(ind(1),:);
        clcdfittest=clcd(ind(1));
        if clcdfittest==clcdoriginal
            fittest = p0;
        end
else 
    range  = [cst02(1) cst03(1) cst02(2) cst03(2) cst02(3) cst03(3) cst02(4) cst03(4) cst02(5) cst03(5) cst02(6) cst03(6) cst02(7) cst03(7) cst02(8) cst03(8) cst02(9) cst03(9)];     
    for k=1:genNo
            q= k-1;
            u = ['Current Generation ',num2str(q),' of 30 mutated and cross-overed values (cd) :) -CST boi'];
            disp(u);
        clcd=[];
        cst=[];

        %population evaluation (starting from the second generation)
        
        
        for i=1:length(newpop)
             u = 'Pop is evaluating  Gen values;)';
            disp(u);
            cst1=newpop(i,:);
            foil = CSTForFitBuild(x,cst1,5,0.5,1);                             % Change N1, N2 if needed 
            buildfile('opt4412).DAT',x,foil)
            [~,~, ~, clcdnew] = xfoil(R,M);  %fitness evaluation
            clcd = [clcd;clcdnew];                                                         %#ok<AGROW> 
            cst = [cst;cst1];                                                              %#ok<AGROW> 
        end
        %first population initialization
        for i=1:popsize-length(newpop)
            o = popsize-i;
             u = ['pop is yet to initialize ',num2str(o),' values - first Gen :/'];
            disp(u);
            cst1 = randcst(cst0,range);
            foil = CSTForFitBuild(x,cst1,5,0.5,1); 
            buildfile('opt4412).DAT',x,foil);
            [~, ~, ~, clcdnew] = xfoil(R,M);    %fitness evaluation
            clcd = [clcd;clcdnew];                                                           %#ok<AGROW> 
            cst = [cst;cst1];                                                                %#ok<AGROW> 
        end
        pop=cst;
        %constraining the coeffecient of lift
        for i=1:length(clcd)
        if clcd(i)<=clcdoriginal
                clcd(i)=clcdoriginal;                                                    %#ok<AGROW> 
        end
        end
        %sorting the individuals by the fittest
        fi=clcd./sum(clcd);
        [fittest,ind] = sort(fi,'descend');
        fittest = fittest(1:ceil(transprob*popsize));                                %#ok<NASGU> 
        ind = ind(1:ceil(transprob*popsize));
        
        if k~=genNo
            newpop = pop(ind,:);
            %crossover
            for i=1:ceil(crossprob*popsize)
                indv1=randi([1,popsize],1);
                indv2=randi([1,popsize],1);
                crossindex=randi([1,9],1);
               newpop=[newpop;pop(indv1,1:crossindex) pop(indv2,crossindex+1:end)]; %#ok<AGROW> 
            end
            %mutation
            for i=1:ceil(mutprob*popsize)
                indv=pop(randi([1,popsize],1),:);
                mutindex=randi([1,9],1);
                pmut=randcst(cst0,range);
                indv(mutindex)=pmut(mutindex);
                newpop=[newpop;indv];                                               %#ok<AGROW> 
            end
        end
        end
        %choosing the tournemnt winner or the most evolved individual
        fittest = pop(ind(1),:);
        clcdfittest=clcd(ind(1));
        if clcdfittest==clcdoriginal
            fittest = cst0;
        end

    
end
if ohio == 1
    fittest2 = pop(ind(2),:);
    clcdfittest2 = clcd(ind(2));
    Result_optclcd = vertcat(fittest,fittest2);
    foil4(:,1) = ParsecForFitBuild(x,Result_optclcd(1,:));
    foil4(:,2) = ParsecForFitBuild(x,Result_optclcd(2,:));
else
    fittest2 = pop(ind(2),:);
    clcdfittest2 = clcd(ind(2));
    Result_optclcd = vertcat(fittest,fittest2);
    foil4(:,1) = CSTForFitBuild(x,Result_optclcd(1,:),5,0.5,1);
    foil4(:,2) = CSTForFitBuild(x,Result_optclcd(2,:),5,0.5,1);
end
foil4 = real(foil4);
plot(x,foil4(:,1),"b-");
 buildfile('optclcd1.DAT',x,foil4(:,1));
 buildfile('optclcd2.DAT',x,foil4(:,2));
end

%% Function to build a file
function buildfile(filename,infox,infoy)

infoy = real(infoy);
r =numel(infoy);
q =1;

while q<=100
    if(infoy(q)<=infoy(r-q+1))
         infox(q) = [];
         infoy(q) = [];
         infox(r-q) = [];
         infoy(r-q) = [];
         r=r-2;
         q=1;
    else
        q=q+1;
   end 
end

  g = 1;
for i =2:numel(infoy)
    
if infoy(i-1)~=infoy(i)
   x(g,1)=infox(i-1);                                                       %#ok<AGROW> 
   y(g,1)=infoy(i-1);                                                       %#ok<AGROW> 
   g =g+1;
   if i == numel(infox)
      x(g,1)=infox(i);                                                      %#ok<AGROW> 
      y(g,1)=infoy(i);                                                      %#ok<AGROW> 
   end
end
end

clear infoy
clear infox
infox=x;
infoy=y;

%Saving the dat file
fileID = fopen(filename, "w");
fprintf(fileID,'airfoilboi \n');
 for i=1:numel(infox)
 fprintf(fileID,"%f %f \n",infox(i),infoy(i));
 end
fclose(fileID);
end


%% This is a special randomizer for a given range for the GA to create random individuals for CST
function [p]=randcst(cst0,range)
p = cst0;
if length(range)==length(p)
    p1=2*range(1)*rand+p(1)-range(1);
    p2=2*range(2)*rand+p(2)-range(2);
    p3=2*range(3)*rand+p(3)-range(3);
    p4=2*range(4)*rand+p(4)-range(4);
    p5=2*range(5)*rand+p(5)-range(5);
    p6=2*range(6)*rand+p(6)-range(6);
    p7=2*range(7)*rand+p(7)-range(7);
    p8=2*range(8)*rand+p(8)-range(8);
    p9=2*range(9)*rand+p(9)-range(9);

elseif length(range)==2*length(p)
    p1=(-range(1)+range(2))*rand+range(1);
    p2=(-range(3)+range(4))*rand+range(3);
    p3=(-range(5)+range(6))*rand+range(5);
    p4=(-range(7)+range(8))*rand+range(7);
    p5=(-range(9)+range(10))*rand+range(9);
    p6=(-range(11)+range(12))*rand+range(11);
    p7=(-range(13)+range(14))*rand+range(13);
    p8=(-range(15)+range(16))*rand+range(15);
    p9=(-range(17)+range(18))*rand+range(17);

end
%final random PARSEC parameters
p=[p1 p2 p3 p4 p5 p6 p7 p8 p9];
end

%% This is a special randomizer for a given range for the GA to create random individuals for PARSEC
function [p]=randp(p,range)
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
if length(range)==length(p)
    p1=2*range(1)*rand+p(1)-range(1);
    p2=2*range(2)*rand+p(2)-range(2);
    p3=2*range(3)*rand+p(3)-range(3);
    p4=2*range(4)*rand+p(4)-range(4);
    p5=2*range(5)*rand+p(5)-range(5);
    p6=2*range(6)*rand+p(6)-range(6);
    p7=2*range(7)*rand+p(7)-range(7);
    p8=2*range(8)*rand+p(8)-range(8);
    p9=2*range(9)*rand+p(9)-range(9);
    p10=2*range(10)*rand+p(10)-range(10);
    p11=2*range(11)*rand+p(11)-range(11);
elseif length(range)==2*length(p)
    p1=(-range(1)+range(2))*rand+range(1);
    p2=(-range(3)+range(4))*rand+range(3);
    p3=(-range(5)+range(6))*rand+range(5);
    p4=(-range(7)+range(8))*rand+range(7);
    p5=(-range(9)+range(10))*rand+range(9);
    p6=(-range(11)+range(12))*rand+range(11);
    p7=(-range(13)+range(14))*rand+range(13);
    p8=(-range(15)+range(16))*rand+range(15);
    p9=(-range(17)+range(18))*rand+range(17);
    p10=(-range(19)+range(20))*rand+range(19);
    p11=(-range(21)+range(22))*rand+range(21);
end
%final random PARSEC parameters
p=[p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11];
end