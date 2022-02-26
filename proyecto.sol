// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract platziProyect {

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

    Project public project;

    constructor(
        string memory _id,
        string memory _name,
        string memory _description,
        uint _foundsGoal
    ) {
        project = Project(
            _id,
            _name,
            _description,
            State.Open,
            _foundsGoal,
            0,
            payable(msg.sender)
        );
    }

    event stateChangeEvent(State newState, string projectId);
    event foundEvent(uint amount, string projectId);

    // LOS MODIFIER SON FUNCIONES QUE NOS PERMITE HACER VALIDACIONES ANTES DE EJECUTAR OTRAS FUNCIONES
    modifier onlyOwner() {
        // LA FUNCION require() OBLIGA A CUMPLIR LA CONDICION, DE LO CONTRARIO, RETORNA UN ERROR CON EL STRING QUE LE PASAMOS COMO SEGUNDO PARAMETRO
        require(project.author == msg.sender, "Only the author of the project can change the state");
        //ESTE _ INDICA DESDE DONDE SE INSERTARA NUESTRO MODIFIER (OSEA DESDE DONDE CONTINUA LA OTRA FUNCION)
        _;
    }

    modifier onlyActive() {
        require(project.state != State.Closed, "The project crowdfounding is no longer active");
        _;
    }

    modifier onlyUsers() {
        require(project.author != msg.sender, "The author of the project can't send founds");
        _;
    }

    function sendFund() public payable onlyUsers onlyActive {
        require(msg.value > 0, "The amount must be higher than 0");
        project.author.transfer(msg.value);
        project.founds += msg.value;
        emit foundEvent(msg.value, project.id);
    }

    //DE ESTA MANERA SE LE APLICA UN MODIFIER A UNA FUNCION
    function changeProyectSate(State newState) public onlyOwner {
        require(project.state != newState, "New state must be diferent than actual state");
        project.state = newState;
        emit stateChangeEvent(newState, project.id);
    }

    function createProject(string calldata id, string calldata description, string calldata name, State state, uint foundsGoal ) public {
        require(id.length > 0, "The id can't be empty");
        require(description.length > 0, "The description can't be empty");
        require(name.length > 0, "The name can't be empty");
        require(foundsGoal > 0, "The founds goal can't be empty");
        require(project.state == State.Open, "The project is not open");
        project = Project(
            id,
            description,
            name,
            state,
            foundsGoal,
            0,
            payable(msg.sender)
        );
    }

}