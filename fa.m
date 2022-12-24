clc;
clear;
close all;

%% Problem Definition

CostFunction=@(x) Sphere(x);        % Cost Function

nVar=5;                 % Number of Decision Variables

VarSize=[1 nVar];       % Decision Variables Matrix Size

VarMin=-10;             % Decision Variables Lower Bound
VarMax= 10;             % Decision Variables Upper Bound

%% Firefly Algorithm Parameters

MaxIt=500;          % Maximum Number of Iterations

nPop=40;            % Number of Fireflies

gamma=1;            % Light Absorption Coefficient

beta0=2;            % Attraction Coefficient Base Value

alpha=0.2;          % Mutation Coefficient

alpha_damp=0.99;    % Mutation Coefficient Damping Ratio

delta=0.05*(VarMax-VarMin);     % Uniform Mutation Range

m=2;

%% Initialization

% Empty Firefly Structure
firefly.Position=[];
firefly.Cost=[];

% Initialize Population Array
pop=repmat(firefly,nPop,1);

% Initialize Best Solution Ever Found
BestSol.Cost=inf;

% Create Initial Fireflies
for i=1:nPop
   pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
   pop(i).Cost=CostFunction(pop(i).Position);
   
   if pop(i).Cost<=BestSol.Cost
       BestSol=pop(i);
   end
end

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

%% Firefly Algorithm Main Loop

for it=1:MaxIt
    
    newpop=pop;
    for i=1:nPop
        for j=1:nPop
            if pop(j).Cost<=pop(i).Cost
                rij=norm(pop(i).Position-pop(j).Position);
                beta=beta0*exp(-gamma*rij^m);
                e=delta*unifrnd(-1,+1,VarSize);
                %e=delta*randn(VarSize);
                
                newpop(i).Position=pop(i).Position...
                    +beta*(pop(j).Position-pop(i).Position)...
                    +alpha*e;
                
                newpop(i).Position=max(newpop(i).Position,VarMin);
                newpop(i).Position=min(newpop(i).Position,VarMax);
                
                newpop(i).Cost=CostFunction(newpop(i).Position);
                
                if newpop(i).Cost<=BestSol.Cost
                    BestSol=newpop(i);
                end
            end
        end
    end
    
    % Merge
    pop=[pop
         newpop
         BestSol];  %#ok
    
    % Sort
    [~, SortOrder]=sort([pop.Cost]);
    pop=pop(SortOrder);
    
    % Truncate
    pop=pop(1:nPop);
    
    % Store Best Cost Ever Found
    BestCost(it)=BestSol.Cost;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
    % Damp Mutation Coefficient
    alpha=alpha*alpha_damp;
    
end

%% Results

figure;
%plot(BestCost,'LineWidth',2);
semilogy(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');

