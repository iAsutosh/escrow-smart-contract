// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.7.0;

// Defining a Contract 
contract escrow{ 
  
    // Declaring the state variables 
    address payable public buyer; 
    address payable public seller; 
    address payable public judge;
    uint public disputeTime;
    uint public disputeFee;
    uint256 public holdBalance;
    uint public expiryTime;
    mapping(address => uint256) public funds;
    
    //events
    
  
    // Defining a enumerator 'State' 
    enum State{ 
         
        // Following are the data members 
        AWATE_PAYMNET,
        PAY_TO_CONTRACT,
        AWAIT_FOR_DISPUTE,
        DISPUTE_RAISED,
        SELLER_PAID_FEE,
        COMPLETE  
    } 
  
    // Declaring the object of the enumerator 
    State public state; 
      
    // Defining function modifier 'instate' 
    modifier instate(State expected_state){ 
        require(state == expected_state); 
        _; 
    } 
    //Defining function modifier 'onlyJudge'
    modifier onlyJudge(){
        require(msg.sender == judge);
        _;
    }
  
   // Defining function modifier 'onlyBuyer' 
    modifier onlyBuyer(){ 
        require(msg.sender == buyer); 
        _; 
    } 
  
    // Defining function modifier 'onlySeller' 
    modifier onlySeller(){ 
        require(msg.sender == seller); 
        _; 
    }
    
    // Defining a constructor 
    constructor(address payable _buyer,  
                address payable _seller,uint _disputeTime,uint256 _disputeFee) public{ 
        
        // Assigning the values of the  
        // state variables 
        judge = msg.sender; 
        buyer = _buyer; 
        seller = _seller; 
        state = State.AWATE_PAYMNET;
        disputeTime = _disputeTime;
        disputeFee = _disputeFee;
    }
      
    // Defining function to confirm payment 
    function payment() onlyBuyer payable public {
        require(state == State.AWATE_PAYMNET);
        state = State.PAY_TO_CONTRACT;
        holdBalance = msg.value;
        funds[seller]=msg.value;
        state = State.COMPLETE;
        expiryTime = now + disputeTime;
    }
    
  
    // Raise dispute before expiry time
    function raise_dispute_buyer() onlyBuyer payable public returns (bool sucess){
        require(state == State.COMPLETE);
        require(now < expiryTime);
        if(msg.value >= disputeFee){
        state = State.DISPUTE_RAISED;
        funds[judge] = funds[judge]+ msg.value;
        return true;
        }
    }
    
    //seller will pay fee for dispute decision
    function pay_fee_seller () onlySeller payable public returns (bool sucess){
        require(state == State.DISPUTE_RAISED);
        if(msg.value >= disputeFee){
        state = State.SELLER_PAID_FEE;
        funds[judge] = funds[judge]+ msg.value;
        return true;
        }
    }
    
    //judge will refund_to_buyer if seller refure to pay dispute fee
    function refund_to_buyer () onlyJudge payable public {
        require(state == State.DISPUTE_RAISED);
        buyer.send(holdBalance+disputeFee);
        funds[judge] = funds[judge] - disputeFee;
        funds[seller] = funds[seller] - holdBalance;
        holdBalance = 0;
        state = State.AWATE_PAYMNET;
        expiryTime =0;
    }
    
    //judge will give decision passing winner address
    function give_decision(address winner) onlyJudge public {
        require(state == State.SELLER_PAID_FEE);
        if(buyer == winner){
            buyer.send(holdBalance);
            
        }
        holdBalance = 0;
        state = State.COMPLETE;
        expiryTime = 0;
    }
    // Define function to withdraw ether
    // seller can withdraw finds
    // while seller withdraw we will check any expiry time is present or not.
    function withdraw_seller () onlySeller  payable public {
        require((now > expiryTime) || (state == State.COMPLETE) );
        require(funds[seller] != 0);
        msg.sender.send(funds[msg.sender]);
        funds[msg.sender] = 0;
    }
    //withdraw fee only judge can withdraw 
     function withdraw_fees () onlyJudge  payable public {
        require(funds[judge] != 0);
        msg.sender.send(funds[msg.sender]);
        funds[msg.sender] = 0;
    }
} 
