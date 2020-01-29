var Intercambio = artifacts.require("Intercambio");

contract('Intercambio', function () {
    
    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });
    
    it('should have a contract balance of zero', async function () {
        
        let instance = await Intercambio.deployed();
        // let balance = await instance.getBalance.call(accounts[0]);
        let expected = 0;
        assert.equal(0,expected);
        
        //setup
        // intialize the contract
        
        // excercise
        // get the account balance of the newly instantialized contract
        expected = 0;

        //verification
        assert.equal(expected, expected);

    });
});


contract('Intercambio', function () {
    
    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should allow a tutor to create and fund an account', function () {
        //setup
        //start instance of contract
        //create tutor account 
        //fund tutor account with ether

        // exercise
        // call the createTutor function 
        const expected = 0;

        //verification
        // check to see if tutor account address annd ufnds are correct
        assert.equal(expected, 0);

    });

});


contract('Intercambio', function () {

    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should allow a student to create and fund an account', function () {
        //setup
        //start instance of contract
        //create student account 
        //fund student account with ether

        // exercise
        // call the createTutor function 
        const expected = 0;

        //verification
        // check to see if tutor account address annd ufnds are correct
        assert.equal(expected, 0);

    });

});


contract('Intercambio', function () {

    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should let a tutor withdraw funds', function () {
        // setup
        // start instance of contract
        // have a tutor account with funds
        
        //exercise
        //call the withdraw funds function 
        expected = 0;

        //verification
        assert.equal(expected, 0);

    });

});


contract('Intercambio', function () {

    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should let a student withdraw funds', function () {
        //setup
        // start instance of contract
        // have a tutor account with funds
        
        //exercise
        //call the withdraw funds function 
        expected = 0;

        //verification
        assert.equal(expected, 0);

    });

});


contract('Intercambio', function () {

    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should allow a student to schedule a lesson', function () {
        // setup
        // startup an instance of the contract w/prefunded students and tutor
        
        // exercise
        // call the schedule lesson function
        expectedLessonAddress = 0;

        //verification
        assert.equal(expectedLessonAddress, 0);

    });

});


contract('Intercambio', function () {

    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should pull funds from both the students and tutors accounts after scheduling', function () {
        //setup
        // startup an instance of the contract w/prefunded students and tutor

        //exercise
        // call the schedule lesson function
        // expectedStudentFunds -= lesson stake
        // expectedTutorFunds -= their lesson stake
        expected = 0;

        //verification
        assert.equal(expected, 0);

    });

});


contract('Intercambio', function () {

    before(function() {
         // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should allow a tutor to confirm the lesson', function () {
        //setup
        
        //exercise
        expected = 0;

        //verification
        assert.equal(expected, 0);

    });

});

contract('Intercambio', function () {

    before(function() {
        // runs before all tests in this block
        // create an instance of the contract
        // prefund student account with 10 eth
        // prefund tutor account with 10 eth
      });

    it('should confirm the lesson and transfer funds', function () {
        //setup
        
        //exercise
        expected = 0;

        //verification
        assert.equal(expected, 0);

    });

});



    

  

   


  

    




