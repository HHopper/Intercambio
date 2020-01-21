Avoiding Common Attacks

The underlying purpose of this application is to manage the business logic between students and tutors – buyers and sellers – in a confirmatory environment. That is, students and tutors must be able to manage their simple bank and it must handle the logic of scheduling a lesson, confirming the lesson, and transferring the funds between two possibly untrusted users (whether that be a external user or another untrusted contract. To address the common attack vectors in a logical manner I will go through them sequentially

   1. Re-entracy Attacks

Code Snippet:

function tutorWithdrawFunds(uint Amount) public payable stopIntOverflow(Amount) {
        require(msg.sender == sellers[msg.sender].sellerAddress && sellers[msg.sender].sellerFunds >= Amount);
        sellers[msg.sender].sellerFunds -= Amount;
        (bool success, ) = msg.sender.call.value(Amount)("");
        require(success, "Transfer failed.");
        emit tutorFundsWithdrawn(msg.sender, Amount);
    }

In the case of Rentrancy Attacks, the most obvious candidate for vulnerability are the transfer functions. Beyond the logical checks that ensure the lesson has been confirmed and the caller is either the student or the tutor, the internal accounting work of the value-transfer is conducted prior to the actual value transfer on a variety of functions (studentWithdrawTotalFunds(), tutorWithdrawFunds(), transferFunds() ). What’s more, using a reconciliation model, the function never actually sends funds to external users. This design choice allows for the transfer function to change the state of the student and tutor balances without requiring the transfering of funds to external (potentially untrusted) accounts. Following that, however, a potential user could just repeatedly call the transfer function and drain the student’s funded account. To remedy this attack, the reader will notice the Enum called Status with the two custom types of Scheduled and Closed. This is used to prevent repeated clicking.

   2. Integer Overflow and Underflow

Code Snippet:

 modifier stopIntOverflow(uint input) {
        require(input < 1568026973464049984 && input > 0); 
        _;
    }


Integer overflow and underflow is addressed using a modifier titled stopIntOverflow. It is used to restrict the a maximum and minimum value that the user is allowed to input (in this case, 100 dollars worth of ether as of January 17, 2019). This modifier is applied to every function in which the application could be susceptible to integer overflow and underflow. 


   3. Transaction Ordering and Timestamp Dependence

Code Snippet:

 /// @notice ensures that whatever function is called is called 60 seconds after it is scheduled
    modifier allowed(bytes32 lesson) {
                if(now > lessonmapping[lesson].time + 60){
                        _;
                }
        }

 function lessonConfirmed (bytes32 lessonAddress) allowed(lessonAddress) internal 

As this is a decentralized marketplace timestamping is important for this application to function. A student will schedule a lesson. After which, they will both confirm and funds will be transferred. The main attack vector for transaction ordering and timestamp dependence will, of course, involve fund transfer between the student and the tutors. While certainty not perfect, the primary defense against this manipulation is that both counter-party users will be required to confirm their attendance and the fund transfer is not handled directly by the users (Intercambio.sol Line 209 to 250). In this way, the transfer of value (ether, wei, etc) is not highly dependent on time itself. Finally, there is a modifier included which acts as a speed bump for the transaction. This is used to prevent minor timestamp manipulation regarding lessons

   4. Denial of Service

In a denial of service attack an attacker will attempt to call a revert function that causes the contract to pause and or stop users from accessing. To remedy and minimize the chances of attack the reader will notice that at any given time there are no loops within the contract code and all calls available to external users only affect one given transaction at a time – that is, even if a denial of service attack is somewhat successful the damage is only limited to one transaction at a time; which is itself limited to a maximum of the rate of one hours worth of a tutors time. Additionally, the withdrawal pattern is used for all value transfer between users and with fund extraction. 

   5. Denial of Service by Block Gas Limit (or startGas)

The denial of service by block gas limit attack becomes possible during situations in which a contract loops over array of an undetermined size. With this in mind, there are no loops found within this contract. As is similar to the denial of service attack above, the transaction logic is simple, contains a number of circuit breakers throughout each, and are limited to one transaction at a time. 
     
   6. Force Sending Ether

