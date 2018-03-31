import './MyToken.sol';

contract TeamVesting is MyToken {
    address owner;
    address tokenAddress = 0x7c66659ffafb0cb45c64c11b8f0e82f443b9a96b;
    function TeamVesting(){
        owner = msg.sender;
        
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
        
    }
    
    //this 
    MyToken m = MyToken(tokenAddress);
    struct BenfeciaryGrant {
        uint value;
        bool revokable;
        uint startTime;
        uint endTime;
        uint cliffTime;
        uint usedTokens;
    }
  mapping(address => BenfeciaryGrant) benfeciaryGrants;
  //total vesting which is already done;
  uint public totalVestingAmount;
  function grantToBeneficiary(uint _value,address _beneficiaryAddress,bool _revokable,uint _startTime,uint _endTime,uint _cliff) onlyOwner
  {
      
        require(safeAdd(totalVestingAmount,_value) <= m.balanceOf(tokenAddress) );
        require(_beneficiaryAddress != address(0));
        require(_value > 0);

        // Make sure that a single address can be granted tokens only once.
        require(benfeciaryGrants[_beneficiaryAddress].value == 0);
     
        benfeciaryGrants[_beneficiaryAddress].value = _value;
        benfeciaryGrants[_beneficiaryAddress].revokable = _revokable;
        benfeciaryGrants[_beneficiaryAddress].startTime = _startTime;
      benfeciaryGrants[_beneficiaryAddress].endTime = _endTime;
        benfeciaryGrants[_beneficiaryAddress].cliffTime = _cliff;
        totalVestingAmount=+_value;
        
        
      
  }
  function getVestedTokens(address _beneficiaryAddress,uint _anyTimeStamp) public constant returns (uint) {
      BenfeciaryGrant grant = benfeciaryGrants[_beneficiaryAddress];
     
      if(grant.value == 0 ){
          return 0;
      }
      if( _anyTimeStamp < grant.cliffTime){
          return 0;
      }
     if (_anyTimeStamp >= grant.endTime) {
            return grant.value;
        }
        uint duration =  grant.endTime - grant.startTime;
        
      
     uint  tokensMulTime = safeMul(grant.value,(safeSub(_anyTimeStamp,grant.startTime)));
     return tokensMulTime / duration;
      
      
  }
  function transferTokens() public {
      BenfeciaryGrant grant = benfeciaryGrants[msg.sender];
     require(grant.value != 0);
     uint vestedTokens = getVestedTokens(msg.sender,block.timestamp);
     if(vestedTokens == 0){
         return;
     }
          uint tokensLeft = safeSub(vestedTokens,grant.usedTokens);
          if(tokensLeft == 0){
              return;
          }
         
          grant.usedTokens = safeAdd(grant.usedTokens,tokensLeft);
          totalVestingAmount = safeSub(totalVestingAmount,tokensLeft);
           m.transfer(msg.sender,tokensLeft);
          
          
          
      
  }
  function getCurrentVestedTokens() public constant returns (uint){
      return getVestedTokens(msg.sender,block.timestamp);
  }
  function revokeVesting(address beneficiary) onlyOwner {
      BenfeciaryGrant grant = benfeciaryGrants[beneficiary];
     require(grant.revokable);
     uint refund = safeSub(grant.value,grant.usedTokens);
     totalVestingAmount = safeSub(totalVestingAmount,refund);
     m.transfer(msg.sender,refund);
     
   
      
  }

    
    function showTokenPrice() public constant returns (uint) {
        
        return m.getPrice();
        
    }
    
}