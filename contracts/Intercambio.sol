pragma solidity ^0.5.0;

///the purpose of this contract is to create a market, manage accounts, and to handle the lesson logic between students and tutors
contract Intercambio {

bool marketexists; ///tells us if the market exists 
address mktOwner; ///state var that tells us who owns the marketplace
address mktAddress; ///market address
uint mktcreationcount;
mapping (address => Seller) sellers; ///mapping used to access the struct Seler
mapping (address => Buyer) buyers; ///mapping used to access the struct Buyer
mapping (bytes32 => lessonStruct) lessonmapping; ///
address[] sellersAddressesArray; ///stores the addresses of the teachers for reference in the mapping
address[] buyerAddressesArray;///stores the addresses of the students for reference in the mapping
bytes32[] lessonAddressesArray; ///stores the addresses of the lessons
bool public contractPaused = false;

///a tutor with a series of attributes
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

///a lesson with a series of attributes
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
    uint time;
}

event tutorAccountCreated (address tutor, uint hourlyRate, uint depositAmount); /// front end knows tutor account created
event studentAccountCreated (address student, uint depositAmount); /// front end knows tutor account created
event studentAccountFunded(address studentAddress, uint fundAmount); ///lets front end know that a student's account was funded
event studentFundsWithdrawn(address studentAddress, uint amount); ///lets front end know that a tutor's or student's funds were withdrawn
event tutorFundsWithdrawn(address tutorAddress, uint amount); ///lets front end know a tutor has withdrawn funds
event lessonScheduled(address tutorAddress, address studentAddress, bytes32 lessonAddress); ///lets front end know lesson was scheduled
event studentConfirmedLesson(address student); ///lets front end know the student confirmed the lesson has happened
event tutorConfirmedLesson(address tutor); ///lets the front end know the tutor has confirme the lesson has happened
event lessonLogConfirmed(address tutor, address student, bytes32 lessonAddress); ///lets the front end know the lesson is officially confirmed
event transferCompleted(address tutor, address student, uint transferAmt, bytes32 lessonAddress);

///ensures that the market for language exchange actually exists
modifier creation () {
     if (marketexists == true) {
        _; } else {
            revert();
        }
}

///ensures that only the market owner can do this 
modifier onlyOwner() {
    if(msg.sender == mktOwner) { _;} 
}

///circuitBreaker to see if the function is paused 
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

///constructor that sets the market information
constructor () public onlyOnce() {
    marketexists = true; 
    mktAddress = msg.sender;
    mktcreationcount = 1; 
    mktOwner = msg.sender;
} 


///allows us to pause the market functionality
function circuitBreaker() public onlyOwner() { // onlyOwner can call
    if (contractPaused == false) { contractPaused = true; }
    else { contractPaused = false; }
}

///creates a tutor with a series of attributes
function createTutor(uint setRate) payable public {
    ///checks to see if there is already a tutor at this address
    require(setRate <= 10000000000, "Stop trying to overflow the contract ya jerk."); ///stops integer overflow for users
    require(sellers[msg.sender].existance != true, "There is already a tutor at this address."); /// makes sure the person doesn't already have an account
    Intercambio.Seller storage tutor = sellers[msg.sender]; 
    tutor.sellerAddress = msg.sender;
    tutor.hourlyRate = setRate;
    tutor.sellerFunds = msg.value;
    tutor.existance = true;
    sellersAddressesArray.push(msg.sender);
    emit tutorAccountCreated(msg.sender, setRate, msg.value); /// emits tutor creation event
}

///creates a language learner with a series of attributes
function createStudent() payable public {
    require(buyers[msg.sender].started != true, "There is already a student at this address."); ///checks to see if there is already a student at this address
    Intercambio.Buyer storage student = buyers[msg.sender]; ///creates and instance of student and assigned _address to mapping
    student.buyerAddress = msg.sender; ///assigns address to struct
    student.buyerFunds = msg.value; /// assigns initial balance of student funds to the value in the transaction
    student.started = true; ///assigns bool to true to prove for later reference
    buyerAddressesArray.push(msg.sender); ///adds the new address to the student addresses array
    emit studentAccountCreated(msg.sender, msg.value); ///tells the front end a new student has been created
}

/// funds a student account given that the account exists
function fundStudentAccount () public payable returns (bool) {
    require(buyers[msg.sender].started == true && buyers[msg.sender].buyerAddress == msg.sender); ///requires the person calling the function to already have a student address and it exists
    buyers[msg.sender].buyerFunds += msg.value; ///assigns the value sent along with the transaction to be stored in this contract
    return true;
    emit studentAccountFunded(msg.sender, msg.value); ///tells front end account has been funded
}
///allows the students to withdraw their funds 
function studentWithdrawTotalFunds(uint Amount) public {
      require(msg.sender == buyers[msg.sender].buyerAddress && buyers[msg.sender].buyerFunds >= Amount);
      buyers[msg.sender].buyerFunds -= Amount;
      msg.sender.transfer(Amount);
      emit studentFundsWithdrawn(msg.sender, Amount);
   }

///allows the tutor to withdraw their funds
function tutorWithdrawFunds(uint Amount) public {
      require(msg.sender == sellers[msg.sender].sellerAddress && sellers[msg.sender].sellerFunds >= Amount);
      sellers[msg.sender].sellerFunds -= Amount;
      msg.sender.transfer(Amount);
      emit tutorFundsWithdrawn(msg.sender, Amount);
   }

///this function schedules a lesson and then it also stakes funds
function scheduleLesson(address tutor) public payable returns(bytes32, uint) { 
    require((buyers[msg.sender].started == true && tutor != msg.sender && sellers[tutor].sellerFunds > sellers[tutor].hourlyRate), "It seems that either you don't have an account, you ACTUALLY ARE THE TUTOR - SAVEY?, or your tutor doesn't have the required stake amount."); ///require the tutor and student both exist and they aren't the same
    sellers[tutor].lessonCount += 1; ///adds a lesson count to the seller's struct for hash
    bytes32 lessonAddress = keccak256(abi.encode(tutor, msg.sender, sellers[tutor].lessonCount));  ///combines student and tutor's address together to create lesson
    lessonmapping[lessonAddress].tutor = tutor; ///sets the tutor of the lesson to the tutor's address
    lessonmapping[lessonAddress].student = msg.sender; ///sets the student of the lesson to the student's address 
    lessonmapping[lessonAddress].rate = sellers[tutor].hourlyRate; ///changes the lesson struct to reference the hourly rate for later transfer -- NEED TO WORK ON THIS
    uint timeScheduled = now;
    lessonmapping[lessonAddress].time = timeScheduled;
    if(sellers[tutor].sellerFunds < sellers[tutor].hourlyRate) { 
        lessonAddressesArray.push(lessonAddress);
        return (lessonAddress, timeScheduled); 
        
    } else {
        stakeFunds(tutor, lessonAddress); ///calls stake funds to put funds in escro. Student stakes 100% of funds and teacher stakes 25%
        lessonAddressesArray.push(lessonAddress);
        return (lessonAddress, timeScheduled); /// tells us that lines 30 to 35 worked and tells us that 
        }
    emit lessonScheduled(tutor, msg.sender, lessonAddress);    
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
        emit tutorConfirmedLesson(msg.sender);
    } else {
        return true;
        emit tutorConfirmedLesson(msg.sender);
        emit lessonLogConfirmed(msg.sender, lessonmapping[lessonAddress].student, lessonAddress);
    }
}

///this function allows students to confirm the lesson
function studentConfirmLesson (bytes32 lessonAddress) public returns (bool) { 
    require(lessonmapping[lessonAddress].student == msg.sender, "You are not the student of this lesson.");     ///requires the student confirming to be the student
    lessonmapping[lessonAddress].studentconfirmed = true;
    emit studentConfirmedLesson(msg.sender); ///lets the front end know the student has confirmed the lesson
    ///if the tutor has also confirmed it, call lessonConfirmed
    if (lessonmapping[lessonAddress].tutorconfirmed == true) {
        lessonConfirmed(lessonAddress);
    } else {
        return true;
    }
}

///confirms that the lesson has been confirmed prior to transfer
function lessonConfirmed (bytes32 lessonAddress) internal {
    //if it is more than a month after the scheduled lesson time, confirm it as true, if not, require both tutor and student to confirm
    if(now > lessonmapping[lessonAddress].time + 2700000) { /// if now is greater than the schedule time + 30 days (in seconds) autoconfirm the lesson happened
        lessonmapping[lessonAddress].lessonConfirmed = true;
        emit lessonLogConfirmed(lessonmapping[lessonAddress].tutor, lessonmapping[lessonAddress].student, lessonAddress);
    } else {
    require (lessonmapping[lessonAddress].studentconfirmed == true && lessonmapping[lessonAddress].tutorconfirmed == true); ///requires both student and tutors confirm, then either can call
    lessonmapping[lessonAddress].lessonConfirmed = true; /// changes the state variable to true
    emit lessonLogConfirmed(lessonmapping[lessonAddress].tutor, lessonmapping[lessonAddress].student, lessonAddress);
    }
}

///tranfers funds between students and tutors after the lesson
function transferFunds(bytes32 lesson) public payable checkIfPaused() returns (bool) {
    require(lessonmapping[lesson].lessonConfirmed == true, "Either the lesson has not been confirmed or you're trying to steal money."); ///requires lesson is confirmed (and switch hasn't been flipped)
    require((lessonmapping[lesson].student == msg.sender || lessonmapping[lesson].tutor == msg.sender), "It looks like you're neither the student or teacher."); ///requires the person calling is the student or tutor
    uint tutorAmt = lessonmapping[lesson].tutorstake; ///sets the tutor amount for 
    lessonmapping[lesson].studentstake = 0; ///sets the stake amount to 0
    lessonmapping[lesson].tutorstake = 0; ///sets the stake amount to 0
    uint tutorDeposit =  (tutorAmt * 125) /100;
    sellers[lessonmapping[lesson].tutor].sellerFunds += tutorDeposit; /// reconciles the stakes and adds it back to the tutor's balance (their stake plus student stake (1 hour)
    lessonmapping[lesson].lessonConfirmed = false; ///flips the switch so it can't be called again.
    return true; /// returns true to represent that the transfer has occured
    emit transferCompleted(lessonmapping[lesson].tutor, lessonmapping[lesson].student, tutorDeposit, lesson);
}  

///see the info about the lesson
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

///see the adddresses of all the tutors
function getAllTutors () public view returns (address[] memory ) {
    return sellersAddressesArray;
}

///see the address of all the students
function getAllStudents () public view returns (address[] memory ) {
    return buyerAddressesArray;
}

///see info of the jefe that ownes the market
function getMktOwner () public view returns (bool, address, address, uint) {
    return (marketexists, mktOwner, mktAddress, mktcreationcount);
}

}
