// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract platziProyect {

    Project public porjects;
    struct Contribution {
        uint amount;
        address contributor;
    } 
    
    mapping(string => Contribution[]) public contributions;

    struct Project {
        string id;
        string description;
        string name;
        State state;
        uint foundsGoal;
        uint founds;
        address payable author;
    }
    enum State { Open, Closed }

    Project[] public projects;

    event stateChangeEvent(State newState, string projectId);
    event foundEvent(uint amount, string projectId);

    // LOS MODIFIER SON FUNCIONES QUE NOS PERMITE HACER VALIDACIONES ANTES DE EJECUTAR OTRAS FUNCIONES
    modifier onlyOwner(uint256 projectIndex) {
        // LA FUNCION require() OBLIGA A CUMPLIR LA CONDICION, DE LO CONTRARIO, RETORNA UN ERROR CON EL STRING QUE LE PASAMOS COMO SEGUNDO PARAMETRO
        require(projects[projectIndex].author == msg.sender, "Only the author of the project can change the state");
        //ESTE _ INDICA DESDE DONDE SE INSERTARA NUESTRO MODIFIER (OSEA DESDE DONDE CONTINUA LA OTRA FUNCION)
        _;
    }

    modifier onlyActive(uint256 projectIndex) {
        require(projects[projectIndex].state != State.Closed, "The project crowdfounding is no longer active");
        _;
    }

    modifier onlyUsers(uint256 projectIndex) {
        require(projects[projectIndex].author != msg.sender, "The author of the project can't send founds");
        _;
    }

    function sendFund(uint256 projectIndex) public payable onlyUsers(projectIndex) onlyActive(projectIndex) {
        require(msg.value > 0, "The amount must be higher than 0");
        Project memory project = projects[projectIndex];
        project.author.transfer(msg.value);
        project.founds += msg.value;
        emit foundEvent(msg.value, project.id);
    }

    //DE ESTA MANERA SE LE APLICA UN MODIFIER A UNA FUNCION
    function changeProyectSate(State newState, uint256 projectIndex) public onlyOwner(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != newState, "New state must be diferent than actual state");
        project.state = newState;
        emit stateChangeEvent(newState, project.id);
    }

    function createProject(string calldata id, string calldata description, string calldata name, State state, uint foundsGoal ) public {
        require(foundsGoal > 0, "Founds goal must be greater than 0");
        Project memory project = Project(
            id,
            description,
            name,
            state,
            foundsGoal,
            0,
            payable(msg.sender)
        );

        projects.push(project);
    }

}