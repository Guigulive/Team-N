pragma solidity ^0.4.14;

contract Payroll{
    uint salary = 1 ether; 
    address staffAccount ; 
    uint constant payDuration = 10 seconds; 
    uint lastPayday = now ;
    
    function  Payroll(){
        staffAccount = msg.sender ;
    }
    
    function addFund() public payable returns (uint){
        return this.balance;
    }
    
    function caculateRunway() public returns (uint){
        return  this.balance / salary ;
    }
    
    function hasEnoughFund() public returns (bool) {
        return caculateRunway() >= 1;
    }
    
    function executePaid() public {
         if(staffAccount != msg.sender){
            revert;
        }
        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now && hasEnoughFund()){
            revert();
        }
        lastPayday = nextPayday;
        staffAccount.transfer(salary);
    }
    
    
    function checkSalaryAndBalance() returns (string){
        return strConcat("currentSalary:" , uint2str(salary), ";balance:", uint2str(this.balance),"") ;
    }
    
    function updateSalary(uint newSalary) public returns (uint){
        if(staffAccount != msg.sender){
            revert;
        }
        salary = newSalary;
    }
    

    function updateAddress(address newAddress) public {
        if(staffAccount != msg.sender){
            revert;
        }
        staffAccount = newAddress;
    }
    
    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
    
    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
   
    
}