// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
      
    enum State {Active,Inactive}
    
    struct Project{
        string id;
        string name;
        string description;
        address payable author;
        State state;
        uint funds;
        uint fundsraisingGoal;
    }

    Project[] public projects;
    mapping (string => uint) public contributions;

    constructor() { }

    modifier onlyAuthor(uint index){
        require(
            msg.sender == projects[index].author,
            "Debes ser el creador del proyecto"
        );
        _;
    }

    modifier onlyExternalAport(uint index){
        require(
            msg.sender != projects[index].author,
            "No puede aportar a su propio poryecto"
        );
        require(projects[index].state != State.Inactive ,"No se puede aportar a proyectos cerrados");
        require(msg.value > 0,"El valor debe ser mayot que 0");
        _;
    }

    event AddToProject(
        uint amount,
        address sender,
        uint actualAmount,
        string project
    );

    event ActualityProjectStatus(
        State status,
        string project
    );
    
    function fundProject(uint position) public  payable  onlyExternalAport(position){
        projects[position].author.transfer(msg.value);
        projects[position].funds += msg.value;
        contributions[projects[position].name] = projects[position].funds;
        emit AddToProject(
            msg.value,msg.sender,projects[position].funds,projects[position].name
        );
    }

    event NewProject(
        Project project
    );

    function addProject(
        string calldata _id,
        string calldata _name,
        string calldata _description,
        uint256 _fundraisingGoal
    ) public {
        require(_fundraisingGoal > 0, "fundraising goal must be greater than 0");
        Project memory newProject = Project(_id,_name,_description,payable(msg.sender),State.Inactive,0,_fundraisingGoal);
        projects.push(newProject);
        contributions[_name] = 0;
        emit NewProject(
            newProject
        );
    }

    function changeProjectState(State newState, uint projectIndex) public onlyAuthor(projectIndex) {
        require(newState != projects[projectIndex].state,"Debe ser un estado diferente");
        projects[projectIndex].state = newState;
        emit ActualityProjectStatus(
            projects[projectIndex].state, projects[projectIndex].name
        );
    }
}