var Intercambio = artifacts.require("./Intercambio.sol");
var Web3 = require('web3'); // imports web3 to the test directory

var web3 = new Web3('ws://localhost:8545'); // creates a new instance of web 3
web3.setProvider('ws://localhost:8545'); //sets the provider (what's the provider?) to local host 8545

contract('Intercambio', function (accounts) {    

    /// @dev this test is used to make sure that one of the key functions doesn't get called upon deployment. 

    it('when the contract is first deployed the circuit breaker should be false', async () => {
        //setup 
        const intercambioInstance = await Intercambio.deployed({from : accounts[0]});
        
        //exercise 
        const result = await intercambioInstance.getCircuitBreakerInfo.call({from : accounts[0]});
        const expected = false;
        
        //assert
        assert.equal(result, expected , "the circuit breaker is true");
    });

    ///@dev this test is used to check the key functionality of the market owner - effectively the admin. Only the owner can call things like the circuit breakers
    it('the user that deployed the contract should be the market owner', async () => {
        //setup 
        const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); //deploys the contract from account 0, which assigns as owner
        
        //exercise 
        const result = await intercambioInstance.getMktOwner.call({from : accounts[0]});
        const expected = accounts[0];
       
        //assert
        assert.equal(result[1], expected, "the person that deployed the contract is not the market");
    });


    ///@dev this test makes sure the students can actually create and fund accounts. It's the foundation of the escro functionality later on.
    it('should allow a student to create and fund an account', async () => {
        //setup
        const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); // account 0 creates an instance
        deployer = accounts[0]; // account zero is the deployer
        studentAccount = accounts[1]; // account 1 is the first student (used for set-up)
        var studentBalance = 10000; // sets the student balance
        tutorAccount = accounts[2]; // account 2 is the first tutor (used for set-up)
        var tutorBalance = 10000; // tutor balance (used for set-up)



        // call the createTutor function 
        await intercambioInstance.createStudent({from: studentAccount, value: 1000}); // calls the method  .createstudent and funds account with 1000 wei
        const currentStudentBalance = await intercambioInstance.getStudentInfo(studentAccount, {from: studentAccount}); // calls the student info 
        const result = currentStudentBalance["1"].toString(10); // converts second key value pair to a string from a big number
        const expected = "1000";

        //verification
        // check to see if tutor account address annd ufnds are correct
        assert.equal(result , expected);

    });

    /// @dev this checks the same functionality but for tutors. It is needed to make sure the tutors can actually put in funds to make money. 
    it('should allow a tutor to create and fund an account', async () => {
        //setup
        const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); // account 0 creates an instance
        deployer = accounts[0]; // account zero is the deployer
        studentAccount = accounts[1]; // account 1 is the first student (used for set-up)
        var studentBalance = 10000; // sets the student balance
        tutorAccount = accounts[2]; // account 2 is the first tutor (used for set-up)
        var tutorBalance = 1000; // tutor balance (used for set-up)



        // call the createTutor function 
        await intercambioInstance.createTutor(100 , {from: tutorAccount, value: tutorBalance}); // calls the method  .createsTutor and funds account with 100 wei
        const currentTutorBalance = await intercambioInstance.getTutorInfo(tutorAccount); // calls the student info 
        
        const result = currentTutorBalance["0"].toString(10); // converts second key value pair to a string from a big number
        const expected = "1000";


        //verification
        // check to see if tutor account address annd ufnds are correct
        assert.equal(result , expected);

    });
    
    ///@dev this test checks to see if students can actually withdraw funds. This is key for account management 
    it('should let a student withdraw funds', async () => {
           //setup
           const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); // account 0 creates an instance
           deployer = accounts[0]; // account zero is the deployer
           studentAccount = accounts[4]; // account 1 is the first student (used for set-up)
           var studentDeposit = 10000; // sets the student balance
           tutorAccount = accounts[2]; // account 2 is the first tutor (used for set-up)
           var tutorBalance = 10000; // tutor balance (used for set-up)
           var studentWithdrawalAmount = 9;
   
   
   
           // call the createTutor function 
           await intercambioInstance.createStudent({from: studentAccount, value: studentDeposit}); // calls the method  .createstudent and funds account with 1000 wei
           await intercambioInstance.getStudentInfo(studentAccount, {from: studentAccount}); // calls the student info 
           await intercambioInstance.studentWithdrawTotalFunds(studentWithdrawalAmount, {from: studentAccount});
           const studentAfterWithdrawal = await intercambioInstance.getStudentInfo(studentAccount);
           
           const result = studentAfterWithdrawal["1"].toString(10); // converts second key value pair to a string from a big number
           expected = "9991";

        //verification
        assert.equal(result, expected);

    });

    ///@dev this test checks to see if tutors can actually withdraw funds. This is key for account management 
    it('should let a tutor withdraw funds', async () => {
       //setup
       const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); // account 0 creates an instance
       deployer = accounts[0]; // account zero is the deployer
       studentAccount = accounts[4]; // account 1 is the first student (used for set-up)
       var studentDeposit = 10000; // sets the student balance
       tutorAccount = accounts[5]; // account 2 is the first tutor (used for set-up)
       var tutorDeposit = 10000; // tutor balance (used for set-up)
       var tutorWithdrawalAmount = 9;



       // call the createTutor function 
       await intercambioInstance.createTutor(100, {from: tutorAccount, value: tutorDeposit}); // calls the method  .createstudent and funds account with 1000 wei
       await intercambioInstance.getTutorInfo(studentAccount, {from: tutorAccount}); // calls the tutor info 
       await intercambioInstance.tutorWithdrawFunds(tutorWithdrawalAmount, {from: tutorAccount}); //calls the withdraw funds method
       const tutorAfterWithdrawal = await intercambioInstance.getTutorInfo(tutorAccount); // calls the get tutor info read-only method
       const result = tutorAfterWithdrawal["0"].toString(10); // converts second key value pair to a string from a big number
       expected = "9991";

    //verification
    assert.equal(result, expected);
    });

    ///@dev this test checks to see if, upon scheduling, the escro functionality actually works for the student. It is key to ensure that both students and tutors actually conduct the lesson. 
    it('should allow a student to schedule a lesson and withdraw funds from the student account', async () => {
        // setup
        const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); // account 0 creates an instance
        deployer = accounts[0]; // account zero is the deployer
        studentAccount = accounts[0]; // account 1 is the first student (used for set-up)
        var studentDeposit = 10000; // sets the student balance
        tutorAccount = accounts[1]; // account 2 is the first tutor (used for set-up)
        var tutorDeposit = 10000; // tutor balance (used for set-up)
        var tutorRate = 100; 
        
        
        // exercise
        await intercambioInstance.createStudent({from: studentAccount, value: studentDeposit}); // creates a student
        await intercambioInstance.createTutor(tutorRate , {from: tutorAccount, value: tutorDeposit}); // calls the method  .createsTutor and funds account with 100 wei    
        let lessonScheduled = await intercambioInstance.scheduleLesson(tutorAccount, {from: studentAccount} );
        let studentBalanceAfterSchedule = await intercambioInstance.getStudentInfo(studentAccount);
        const result = studentBalanceAfterSchedule["1"].toString(10); // converts second key value pair to a string from a big number
        
        
        expectedStudentBalanceAfterSchedule = "9900";


        //verify
        assert.equal(result, expectedStudentBalanceAfterSchedule, "the student amount didn't get subtracted");

    });

    ///@dev this test checks to see if, upon scheduling, the escro functionality actually works for the tutor. It is key to ensure that both students and tutors actually conduct the lesson.    
    it('should pull funds from both the students and tutors accounts after scheduling', async () => {
         // setup
         const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); // account 0 creates an instance
         deployer = accounts[0]; // account zero is the deployer
         studentAccount = accounts[5]; // account 1 is the first student (used for set-up)
         var studentDeposit = 10000; // sets the student balance
         tutorAccount = accounts[0]; // account 2 is the first tutor (used for set-up)
         var tutorDeposit = 10000; // tutor balance (used for set-up)
         var tutorRate = 100; // rate for the hourly lesson
         
         
         // exercise
         await intercambioInstance.createStudent({from: studentAccount, value: studentDeposit}); // creates a student
         await intercambioInstance.createTutor(tutorRate , {from: tutorAccount, value: tutorDeposit}); // calls the method  .createsTutor and funds account with 100 wei    
         let lessonScheduled = await intercambioInstance.scheduleLesson(tutorAccount, {from: studentAccount} ); // schedules a lesson 
         let tutorBalanceAfterSchedule = await intercambioInstance.getTutorInfo(tutorAccount); // gets the tutor balance after the student schedules the lesson
         const result = tutorBalanceAfterSchedule["0"].toString(10); // converts second key value pair to a string from a big number

         
         //expected
         expectedTutorBalanceAfterSchedule = "9975";
 
 
         //verify
         assert.equal(result, expectedTutorBalanceAfterSchedule, "the tutor amount didn't get subtracted");

    }); 


    /// @dev this is intended to conduct all the lesson logic and confirm that the lesson closes. 
    it('should flip the lesson confirmed bool to true after both users confirm', async () => {
        // setup
        const intercambioInstance = await Intercambio.deployed({from : accounts[0]}); // account 0 creates an instance
        deployer = accounts[0]; // account zero is the deployer
        studentAccount = accounts[9]; // account 1 is the first student (used for set-up)
        var studentDeposit = 10000; // sets the student balance
        tutorAccount = accounts[7]; // account 2 is the first tutor (used for set-up)
        var tutorDeposit = 10000; // tutor balance (used for set-up)
        var tutorRate = 100; // rate for the hourly lesson
        
        
        // exercise
        await intercambioInstance.createStudent({from: studentAccount, value: studentDeposit}); // creates a student
        await intercambioInstance.createTutor(tutorRate , {from: tutorAccount, value: tutorDeposit}); // calls the method  .createsTutor and funds account with 100 wei    
        await intercambioInstance.scheduleLesson(tutorAccount, {from: studentAccount} ); // schedules a lesson 
        let lessonBytes = await intercambioInstance.getAllLessons({from : studentAccount}); // the lesson information
        let lessonPrior = await intercambioInstance.getLessonInfo(lessonBytes[0], {from: tutorAccount});
        await intercambioInstance.studentConfirmLesson(lessonBytes[0], {from : studentAccount}); // calls student confirmation
        await intercambioInstance.tutorConfirmLesson(lessonBytes[0], {from : tutorAccount}); // calls tutor confirmation
        let resultObject = await intercambioInstance.getLessonInfo(lessonBytes[0], {from: tutorAccount}); // gets the lesson info after to it
        let result = resultObject[5].negative; // this is the Closed Status in BN form 
        
        //expected
        expectedTutorBalanceAfterSchedule = "0"
        
        //verify
        assert.equal(result, expectedTutorBalanceAfterSchedule, "the tutor amount didn't get subtracted");

   }); 


    /// @dev this test makes sure that the market owner can't force send ether to the contract upon deployment. No international swiss funds now.
    it('should have a contract balance of undefined because the constructor is not payable', async () => {
        
        var intercambioObject = new web3.eth.Contract(Intercambio.abi, "0xd286cf078dA0f9d6E1B6f90AD8Ff11571c263bc6"); //should create instance at the specified address
        
        try {

            //tries to pull the current balance of the contract - which, without .send should be zero if the contract accepts value

            const contractBalance = (await intercambioObject.eth.getBalance.call("0xd286cf078dA0f9d6E1B6f90AD8Ff11571c263bc6")).toNumber();
          
          } catch (err) {
          
            var result = "Undefined";
          
          }
             
        let expected = "Undefined";

        assert.equal(result ,expected);

    });
});



