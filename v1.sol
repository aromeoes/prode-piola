// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {
    address owner;
    string statusPool = "open";
    string[3] Fixture = ["a1", "a2", "a3"]; // Le ponemos nombre a los partidos para mayor control de oraculos (x ahora solo 3 partidos)
    string[3] OracleFinalResultsArray; // Aca van en el mismo orden que el fixture, los resultados del oraculo

    constructor() {
        owner = msg.sender; //esto lo hago para definir el oraculo
    }

    mapping(string => string) public oracleFinalResults;

    struct Participant {
        string[3] prediccionFaseGrupos; // prediccion con 3 resultados modelo
        address payable beneficiary; // person placing the bet
        uint256 points; // puntos acumulados
    }

    struct WinnersStruct {
        uint256 maxPoints;
        uint256 quantityWinners;
        uint256[] winnersIndexes;
    }

    WinnersStruct winnersData;
    Participant[] participantArray; // Array con todas las apuestas

    // Funcion que corre cuando un Apostador paga
    function createParticipant(string[3] memory input) public payable {
        require(msg.value == 5000); //Esta es la guita de la apuesta requerida
        require(keccak256(bytes(statusPool)) == keccak256(bytes("open"))); // Esto restringe los nuevos participantes solo cuando el torneo esta abierto
        participantArray.push(Participant(input, payable(msg.sender), 0));
    }

    function retrieveOwner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function temporaryCupBegins() public {
        statusPool = "during"; // a Futuro esto se tiene q cambiar x un timestamp, y tiene q ser automatico el status, no una variable
    }

    function retrieveVars() public view returns (string memory, string memory) {
        return (statusPool, oracleFinalResults["asd"]);
    }

    function retrieveOracleFinalResults()
        public
        view
        returns (string[3] memory)
    {
        return [
            oracleFinalResults["a1"],
            oracleFinalResults["a2"],
            oracleFinalResults["a3"]
        ];
    }

    function retrieveParticipants() public view returns (Participant[] memory) {
        return participantArray;
    }

    function OracleUpdate(string memory game, string memory result)
        public
        onlyOwner
    {
        // Cada update de cada game es unico
        require(keccak256(bytes(statusPool)) == keccak256(bytes("during")));
        require(bytes(oracleFinalResults[game]).length == 0);
        bool validGame = false;
        uint256 gameIndex;
        for (uint256 i = 0; i < Fixture.length; i++) {
            if (keccak256(bytes(Fixture[i])) == keccak256(bytes(game))) {
                OracleFinalResultsArray[i] = result;
                validGame = true;
                gameIndex = i;
            }
        }
        require(validGame == true); // Esto valida que es un partido de los whitelisteados en el fixture
        for (uint256 i = 0; i < participantArray.length; i++) {
            if (
                keccak256(
                    bytes(participantArray[i].prediccionFaseGrupos[gameIndex])
                ) == keccak256(bytes(result))
            ) {
                // Valido que la prediccion sea = al resultado
                participantArray[i].points += 1; //sumo 1 punto por embocarle al resultado
            }
        }
        oracleFinalResults[game] = result;
    }

    function oracleEnd() public onlyOwner {
        // Esta funcion cierra el prode. Define cuantos puntos tuvieron los q mas puntos tuvieron, y dice cuantos fueron, para repartir la guita en base a eso
        require(keccak256(bytes(statusPool)) == keccak256(bytes("during")));
        statusPool = "Finished";
        uint256 maxPoints = 0;
        uint256 quantityWinners = 0;
        for (uint256 i = 0; i < participantArray.length; i++) {
            if (participantArray[i].points == maxPoints) {
                quantityWinners += 1;
                winnersData.winnersIndexes.push(i);
            }
            if (participantArray[i].points > maxPoints) {
                quantityWinners = 1;
                maxPoints = participantArray[i].points;
                delete winnersData.winnersIndexes;
                winnersData.winnersIndexes.push(i);
            }
        }
        winnersData.maxPoints = maxPoints; // la cantida de puntos de los ganadores
        winnersData.quantityWinners = quantityWinners; // la cantidad de ganadores
        uint256 awardWinners = address(this).balance / quantityWinners;
        for (uint256 i = 0; i < winnersData.winnersIndexes.length; i++) {
            participantArray[winnersData.winnersIndexes[i]]
                .beneficiary
                .transfer(awardWinners); // Ver si el redondeado aca trae algun error
        }
    }
}
