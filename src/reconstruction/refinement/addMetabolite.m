function [ newmodel ] = addMetabolite(model,metID,varargin)
% Adds a Metabolite to the Current Reconstruction
%
% USAGE:
%
%    newModel = addMetabolite(model, metID, metName, formula, ChEBIID, KEGGId, PubChemID, InChi, Charge, b)
%
% INPUTS:
%    model:         Cobra model structure
%    metID:         The ID(s) of the metabolite(s) (will be the identifier in model.mets)
%
% OPTIONAL INPUTS:
%    varargin:      Optional Inputs provided as 'ParameterName', Value
%                   pairs. the following parameternames are available:
%                   * metName:       Human readable name(s) (default metID, String)
%                   * metFormula:    The chemical formula(s) (default '', String)
%                   * ChEBIID:       The CHEBI Id(s) (default '', String)
%                   * KEGGId:        The KEGG Compound ID(s) (default '', String)
%                   * PubChemID:     The PubChemID(s) (default '', String)
%                   * InChi:         The InChi description(s) (default '', String)
%                   * Charge:        The Charge(s) (default NaN, int)
%                   * b:             The accumulation(s) or release(s) (default 0, double)
%                   * csense:        The sense of this metabolite (default 'E', char)
%
% OUTPUT:
%    newModel:      COBRA model with added metabolite(s)
%
% EXAMPLES:
%    1) add a Metabolite which should be accumulated
%    model = addMetabolite(model,'MetToAcc','b',5);
%    2) Add a Metabolite with a given Formula and a given Charge
%    model = addMetabolite(model,'MetWithForm','metFormula','H3O','metCharge',1);
% .. Author: - Thomas Pfau 15/12/2014
%
% `metID` and all optional arguments either have to be a single value or cell
% arrays. `Charge` and `b` have to be double arrays.

optionalParameters = {'metName','metFormula','ChEBIID','KEGGId','PubChemID', 'InChi','Charge', 'b', 'csense'};
oldOptionalOrder = {'metName','metformula','ChEBIID','KEGGId','PubChemID', 'InChi','Charge', 'b' };
if (numel(varargin) > 0 && ischar(varargin{1}) && ~any(ismember(varargin{1},optionalParameters)))
    %We have an old style thing....
    %Now, we need to check, whether this is a formula, or a complex setup
    %convert the input into the new format.
    tempargin = cell(0);
    for i = 1:numel(varargin)
        if~isempty(oldOptionalOrder(i))
            if ~isempty(varargin{i})
                tempargin{end+1} = optionalParameters{i};
                tempargin{end+1} = varargin{i};
            end
        end
    end
    varargin = tempargin;
end

% Figure out if reaction already exists
if ~iscell(metID)
    metID = {metID};
end
defaultMetName = metID;
defaultFormula = {''};
defaultCHEBI = {''};
defaultKEGG = {''};
defaultPubChem = {''};
defaultInChi = {''};
defaultCharge = NaN;
defaultb = 0;
defaultCsense = 'E';
if(iscell(metID))
    defaultFormula = repmat(defaultFormula,numel(metID),1);
    defaultCHEBI = repmat(defaultCHEBI,numel(metID),1);
    defaultKEGG = repmat(defaultKEGG,numel(metID),1);
    defaultPubChem = repmat(defaultPubChem,numel(metID),1);
    defaultInChi = repmat(defaultInChi,numel(metID),1);
    defaultCharge = repmat(defaultCharge,numel(metID),1);
    defaultb = repmat(defaultb,numel(metID),1);
    defaultCsense = repmat(defaultCsense,numel(metID),1);
end

parser = inputParser();
parser.addRequired('model',@isstruct) % we only check, whether its a struct, no details for speed
parser.addRequired('metID',@(x) iscell(x) || ischar(x))
parser.addParamValue('metName',defaultMetName,@(x) ischar(x) || iscell(x) )
parser.addParamValue('metFormula',defaultFormula, @(x) ischar(x) || iscell(x));
parser.addParamValue('ChEBIID',defaultCHEBI, @(x) ischar(x) || iscell(x));
parser.addParamValue('KEGGId',defaultKEGG, @(x) ischar(x) || iscell(x));
parser.addParamValue('PubChemID',defaultPubChem, @(x) ischar(x) || iscell(x));
parser.addParamValue('InChi',defaultInChi, @(x)  ischar(x) || iscell(x));
parser.addParamValue('Charge',defaultCharge, @(x) isnumeric(x));
parser.addParamValue('b',defaultb,@(x) isnumeric(x));
parser.addParamValue('csense',defaultCsense, @(x) ischar(x));

parser.parse(model,metID,varargin{:});

nonDefaults = setdiff(setdiff(parser.Parameters,parser.UsingDefaults),{'model','metID'}); %Non Defaults without the originals.
translation = {'b','b',false;...
               'csense','csense',false;...
               'metName','metNames',true;...
               'metFormula','metFormulas',true;...
               'ChEBIID','metChEBIID',true;...
               'KEGGId','metKEGGID',true;...
               'PubChemID','metPubChemID',true;...
               'InChi','metInChIString',true;...
               'Charge','metCharges',false};
multiArgs = {};          
for i = 1:numel(nonDefaults)
    argpos = ismember(translation(:,1),nonDefaults{i});
    val = parser.Results.(nonDefaults{i});
    if translation{argpos,3} && ~iscell(val)
        val = {val};
    end        
    multiArgs((2*(i-1)+1):(2*i)) = {translation{argpos,2},val};
end

newmodel = addMultipleMetabolites(model,metID,multiArgs{:});

end
