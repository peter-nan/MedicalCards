/* @title Smart contract for ownership */
contract Owned {

    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

/* @title Smart contract for medical cards storing */
contract MedCard is Owned {

    // address -> doctor profile
    mapping (address => Doctor) public doctors;

    // address -> patient profile
    mapping (address => Patient) public patients;

    // address -> All medical card records for that patient
    mapping (address => Record[]) private patientRecords;

    // doctor address -> all available for him patient addresses
    mapping (address => PatientProfile[]) private patientsAvailableForDoctor;

    // patient => reqeusts from doctors
    mapping (address => address[]) private requests;

    // address => his private key
    mapping (address => bytes32) public publicKeys;

    // check if _address corresponds to any Doctor
    modifier isDoctor(address _address) {
        require(doctors[_address].accepted);
        _;
    }

    // check if _address dorsn't correspond to any Doctor
    modifier isNotDoctor(address _address) {
        require(!doctors[_address].accepted);
        _;
    }

    // check if _address corresponds to any Patient
    modifier isPatient(address _address) {
        require(bytes(patients[_address].name).length != 0);
        _;
    }

    // check if _address dorsn't correspond to any Patient
    modifier isNotPatient(address _address) {
        require(bytes(patients[_address].name).length == 0);
        _;
    }

    // check if doctor can add records for the patient
    modifier isAvailable(address pateint, address doctor) {
        require(checkIfPatientAvailableForDoctor(pateint, doctor));
        _;
    }

    // This is a type for a single doctor identity
    //TODO think about moving fields in DFS(IPFS/SWARM)
    struct Doctor {
        string name;
        string surname;
        uint passport;
        string workPlace;
        string category;
        bool accepted;
    }

    // This is a type for a simple record
    //TODO store in blockchain only value(without doctorAddress)
    struct Record {
        string value;
        address doctorAddress;
    }
    // This is a type fot doctor's patient profile. Hish address and passphrase
    // with encrypted password for records reading and encrypting
    struct PatientProfile {
        address _address;
        bytes32 passphrase;
    }

    // This is a type for a single patient identity
    //TODO think about moving fields in DFS(IPFS/SWARM)
        struct Patient {
            string name;
            string surname;
            uint passport;
            uint birthday;
            bytes32 passphrase;
    }

    //create new Patient identity
    function applyPatient(string _name,
                          string _surname,
                          uint _passport,
                          uint _birthday,
                          bytes32 _passphrase) public isNotPatient(msg.sender) {
        patients[msg.sender] = Patient({
            passphrase: _passphrase,
            name: _name,
            surname: _surname,
            passport: _passport,
            birthday: _birthday
        });
    }

    // create new Doctor identity
    function applyDoctor(string _name,
                        string _surname,
    uint _passport,
    string _workPlace,
    string _category) public isNotDoctor(msg.sender) {
        doctors[msg.sender] = Doctor({
            name: _name,
            surname: _surname,
            passport: _passport,
            workPlace: _workPlace,
            category: _category,
            accepted: false
        });
    }

    // Approve the address to work as a Doctor in system
    function approveDoctor(address _doctorAddress) public onlyOwner {
        doctors[_doctorAddress].accepted = true;
    }

    // Request patient for access
    function request(address patientAddress) public isDoctor(msg.sender) {
        requests[patientAddress].push(msg.sender);
    }

    function getReqestsLength() public constant returns(uint) {
        return requests[msg.sender].length;
    }

    function considerRequest(uint index, address doctorAddress,
    bool decision,
    bytes32 passphrase) public isPatient(msg.sender) {
        if (decision) {
            patientsAvailableForDoctor[doctorAddress]
                .push(PatientProfile({
                    _address: msg.sender,
                    passphrase: passphrase
                })
            );
        }
        delete requests[msg.sender][index];
    }

    // check if doctor can get patient records
    function checkIfPatientAvailableForDoctor(address _patientAddress,
    address _doctorAddress) public constant returns (bool) {
        PatientProfile[] memory doctorPatients = patientsAvailableForDoctor[_doctorAddress];
        bool availability = false;
        for (uint i = 0; i < doctorPatients.length; i++) {
            if (doctorPatients[i]._address == _patientAddress) {
                availability = true;
            }
        }
        return availability;
    }

    // add new record in medical card
    function addRecord(address patientAddress, string value) public isDoctor(msg.sender) isAvailable(patientAddress, msg.sender) {
        patientRecords[patientAddress]
            .push(Record({
                value: value,
                doctorAddress: msg.sender
            })
        );
    }

    // get length of array with patient records
    function getPatientRecordsLength(address _patientAddress) public constant returns (uint) {
        return patientRecords[_patientAddress].length;
    }

    // get patient record by index
    function getPatientRecord(address _patientAddress, uint _recordIndex) public constant returns (address, string) {
        Record memory record = patientRecords[_patientAddress][_recordIndex];
        return (record.doctorAddress, record.value);
    }
}