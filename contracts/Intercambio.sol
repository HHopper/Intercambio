pragma solidity ^0.5.0;

///the purpose of this contract is to create a market, accounts, and to manager student/tutor funds
contract Intercambio {

bool marketexists;
address mktOwner;
address mktAddress;
uint mktcreationcount;
mapping (address => Seller) sellers; ///givess
mapping (address => Buyer) buyers;
mapping (bytes32 => lessonStruct) lessonmapping;
address[] sellersAddressesArray; ///stores the addresses of the teachers for reference in the mapping
address[] buyerAddressesArray;///stores the addresses of the students for reference in the mapping
bool public contractPaused = false;

struct Seller {
    address sellerAddress;
    uint sellerFunds; 
    bool existance;
    uint lessonCount;
    uint hourlyRate;
}

///a student with a series of essential characteristics
struct Buyer {
    address buyerAddress;
    uint buyerFunds; 
    bool started;
}

struct lessonStruct {
    address tutor; ///address of the tutor
    address student; ///address of the student
    bytes32 lessonAddress; ///SHA256 address of the student and teachers lesson plus a rand var?
    uint rate;
    uint studentstake; ///amount of ether staked by student 
    uint tutorstake; ///amount of ether staked by teacher
    bool scheduled; ///confirmed scheduled
    bool studentconfirmed; ///student confirms lesson
    bool tutorconfirmed; ///teacher  confirms lesson
    bool lessonConfirmed; ///lesson is confirmed
}

event mktcreated(address _owner, bool yup); ///lets front end know that the marketplace was created
event studentAccountFunded(address _address, uint _fundAmount); ///lets front end know that a student's account was funded
event fundsWithdrawn(address _address, uint Amount); ///lets front end know that a tutor's or student's funds were withdrawn

///ensures that the market for language exchange actually exists
modifier creation () {
    if (marketexists == true) {
        _; } else {
            revert();
        }
}
modifier onlyOwner() {
    if(msg.sender == mktOwner) { _;} 
}
modifier checkIfPaused() {
    require(contractPaused == false);
    _;
}
///ensures that the market for students and teachers can only be created one time
modifier onlyOnce() {
    if (mktcreationcount >= 1) {
        revert();
    } else { 
        _; 
    }
}
constructor () public onlyOnce() {
    marketexists = true; 
    mktAddress = msg.sender;
    mktcreationcount = 1; 
    mktOwner = msg.sender;
} 
function circuitBreaker() public onlyOwner() { // onlyOwner can call
    if (contractPaused == false) { contractPaused = true; }
    else { contractPaused = false; }
}
///creates a tutor with a series of attributes
function createTutor(address _address, uint setRate) payable public returns (bool) {
    ///checks to see if there is already a tutor at this address
    require(sellers[_address].existance != true, "There is already a tutor at this address."); 
    Intercambio.Seller storage tutor = sellers[_address]; ///
    tutor.sellerAddress = _address;
    tutor.hourlyRate = setRate;
    tutor.sellerFunds = msg.value;
    tutor.existance = true;
    sellersAddressesArray.push(_address) -1;
    return true;
}
///creates a language learner with a series of attributes
function createStudent(address _address) payable public returns (bool) {
    require(buyers[_address].started != true, "There is already a student at this address."); ///checks to see if there is already a student at this address
    Intercambio.Buyer storage student = buyers[_address]; ///creates and instance of student and assigned _address to mapping
    student.buyerAddress = _address; ///assigns address to struct
    student.buyerFunds = msg.value; /// assigns initial balance of student funds to the value in the transaction
    student.started = true; ///assigns bool to true to prove for later reference
    buyerAddressesArray.push(_address) -1; ///adds the new address to the student addresses array
    return student.started; ///returns the true variable
}
/// funds a student account given that the account exists
function fundStudentAccount () public payable returns (bool) {
    require(buyers[msg.sender].started == true && buyers[msg.sender].buyerAddress == msg.sender); ///requires the person calling the function to already have a student address and it exists
    emit studentAccountFunded(msg.sender, msg.value);
    buyers[msg.sender].buyerFunds += msg.value; ///assigns the value sent along with the transaction to be stored in this contract
    return true;
}
///allows the students to withdraw their entire fund balance 
function studentWithdrawTotalFunds() public {
      uint amount = buyers[msg.sender].buyerFunds;
      buyers[msg.sender].buyerFunds = 0;
      msg.sender.transfer(amount);
      emit fundsWithdrawn(msg.sender, amount);
   }
///allows the tutor to withdraw their entire fund balance 
function tutorWithdrawTotalFunds() public {
      uint amount = sellers[msg.sender].sellerFunds;
      sellers[msg.sender].sellerFunds = 0;
      msg.sender.transfer(amount);
      emit fundsWithdrawn(msg.sender, amount);
   }
///this function schedules a lesson and then it also stakes funds
///Thing to pay attention to the paremeter lessonTime is a uint - this is NOT FINAL BECAUSE i AM WORKING ON DEVELOPING TIME STAMPING
function scheduleLesson(address tutor) public payable returns(bytes32) { 
    require(buyers[msg.sender].started == true && tutor != msg.sender); ///require the tutor and student both exist and they aren't the same
    sellers[tutor].lessonCount += 1; ///adds a lesson count to the seller's struct for hash
    bytes32 lessonAddress = keccak256(abi.encode(tutor, msg.sender, sellers[tutor].lessonCount));  ///combines student and tutor's address together to create lesson
    lessonmapping[lessonAddress].tutor = tutor; ///sets the tutor of the lesson to the tutor's address
    lessonmapping[lessonAddress].student = msg.sender; ///sets the student of the lesson to the student's address 
    lessonmapping[lessonAddress].rate = sellers[tutor].hourlyRate; ///changes the lesson struct to reference the hourly rate for later transfer -- NEED TO WORK ON THIS
    if(sellers[tutor].sellerFunds < sellers[tutor].hourlyRate) { return lessonAddress; } else {
        stakeFunds(tutor, lessonAddress); ///calls stake funds to put funds in escro. Student stakes 100% of funds and teacher stakes 25%
        return lessonAddress; /// tells us that lines 30 to 35 worked 
        }
} 
///this function takes the students funds out of their account, as well as the tutors, as a promise that it'll happen
function stakeFunds(address tutorAddress, bytes32 lessonaddress) private returns(bool) { 
    uint stake  = sellers[tutorAddress].hourlyRate; ///stake amount is the hourlyRate set by the tutor
    buyers[msg.sender].buyerFunds -= stake; ///pulls stake amount from buyer and buyer stakes 100% of stake amount
    sellers[tutorAddress].sellerFunds -= (stake * 25) /100; ///pulls stake amount from seller and seller stakes 20% of stake amount
    lessonmapping[lessonaddress].studentstake += stake; ///adds the students stake to the contract struct
    lessonmapping[lessonaddress].tutorstake += (stake *25) / 100; ///adds the teacher's stake to the contract struct
    return true; ///returns bool to indicate success
    }
///this function allows tutors to confirm the lesson 
function tutorConfirmLesson (bytes32 lessonAddress) public returns (bool) { 
    require(lessonmapping[lessonAddress].tutor == msg.sender, "You are not the tutor."); ///requires the tutor confirming to be the tutor
    lessonmapping[lessonAddress].tutorconfirmed = true; /// changes the state variable to true;
    ///if the tutor has also confirmed it, call lessonConfirmed
    if (lessonmapping[lessonAddress].studentconfirmed == true) {
        lessonConfirmed(lessonAddress);
    } else {
        return true;
    }
}
///this function allows students to confirm the lesson
function studentConfirmLesson (bytes32 lessonAddress) public returns (bool) { 
    require(lessonmapping[lessonAddress].student == msg.sender, "You are not the student of this lesson.");     ///requires the student confirming to be the student
    lessonmapping[lessonAddress].studentconfirmed = true;
    ///if the tutor has also confirmed it, call lessonConfirmed
    if (lessonmapping[lessonAddress].tutorconfirmed == true) {
        lessonConfirmed(lessonAddress);
    } else {
        return true;
    }
}
///should either of these
function lessonConfirmed (bytes32 lessonAddress) internal {
    //requires that both the student and the tutor have confirmed the lesson
    require (lessonmapping[lessonAddress].studentconfirmed == true && lessonmapping[lessonAddress].tutorconfirmed == true); ///requires both student and tutors confirm, then either can call
    lessonmapping[lessonAddress].lessonConfirmed = true; /// changes the state variable to true
}
function transferFunds(bytes32 lesson) public payable checkIfPaused() returns (bool) {
    require(lessonmapping[lesson].lessonConfirmed == true, "Either the lesson has not been confirmed or you're trying to steal money.");
    require((lessonmapping[lesson].student == msg.sender || lessonmapping[lesson].tutor == msg.sender), "It looks like you're neither the student or teacher."); ///requires the person calling is the student or tutor
    uint tutorAmt = lessonmapping[lesson].tutorstake;
    lessonmapping[lesson].studentstake = 0; ///sets the stake amount to 0
    lessonmapping[lesson].tutorstake = 0; ///sets the stake amount to 0
    sellers[lessonmapping[lesson].tutor].sellerFunds += (tutorAmt * 125) /100; /// reconciles the stakes and adds it back to the tutor's balance (their stake plus student stake (1 hour)
    lessonmapping[lesson].lessonConfirmed = false; ///flips the switch so it can't be called again.
    return true; /// returns true to represent that the transfer has occured
}  
function getLessonInfo (bytes32 lessonAddress) public view returns (address, address, bytes32, uint, uint, bool) {
    return (lessonmapping[lessonAddress].tutor, lessonmapping[lessonAddress].student, lessonAddress, lessonmapping[lessonAddress].studentstake, lessonmapping[lessonAddress].tutorstake, lessonmapping[lessonAddress].lessonConfirmed); 
}
///allows us to pull the teacher's information from the blockchain
function getTutorInfo (address _address) public view returns (uint, uint) {
    return (sellers[_address].sellerFunds, sellers[_address].hourlyRate);
}
///allows us to pull the students info from the blockchain
function getStudentInfo (address _address) public view returns (address) {
    return (buyers[_address].buyerAddress);
}

function getAllTutors () public view returns (address[] memory ) {
    return sellersAddressesArray;
}
function getAllStudents () public view returns (address[] memory ) {
    return buyerAddressesArray;
}
function getMktOwner () public view returns (bool, address, address, uint) {
    return (marketexists, mktOwner, mktAddress, mktcreationcount);
}

}