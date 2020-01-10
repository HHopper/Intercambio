pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Intercambio.sol";

contract TestStudentCreation {
    
    function testStudentCreation() public  {

        Intercambio studentCreated = Intercambio(DeployedAddresses.Intercambio());

        address expected = 0x583031D1113aD414F02576BD6afaBfb302140225;

        studentCreated.createStudent(expected);

        assert(studentCreated.getStudentInfo(expected) == expected);

}



/*
Market Functionality
1. create a market for exchange and prove only one market exists (Works)
2. Create accounts for tutors and students (works)
3. Handle the funds for both students and tutors (students: funding and withdraw, tutors: withdraw) (works for student)
4. Query the balances of the students and tutors (works)
Lesson Functionality
1. Schedule a lesson, creating a unique lesson ID (works but without actual time scheduling)
2. Stake funds prior to the lesson to ensure attendance (sort of works)
3. Confirm that the lesson has occurred (works if both parties confirm)
4. After confirmation, transfer funds between the student and the tutors (doesn't work yet)

*/