pragma solidity ^0.4.14;
contract Payroll {
    
    struct Employee{
        address employeeAddress;
        uint salary;
        uint lastPayDay;
    }
    
    Employee[] employees;
  
    uint constant payDuration = 10 seconds;
    address adminAddr = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db; //先给管理员写死一个地址  
    
    //给部分function加管理员权限 
    modifier onlyAdmin(){
        require(msg.sender == adminAddr);
        _;
    }
    
    // 统一支付方法 
    function _partialPaid(Employee e) private returns (bool){
        uint payment = e.salary * (now - e.lastPayDay) / payDuration;
        if(payment > 0){
            e.employeeAddress.transfer(payment);
            return true;
        }else{
            return false;
        }
    }
    
    function _findEmployee(address employeeAddr) private returns (Employee,uint){
        for(uint i = 0; i < employees.length; i++){
            if(employees[i].employeeAddress == employeeAddr){
                return (employees[i],i);
            }
        }
    }
    
    //添加人员
    function AddEmployee(address employeeAddr,uint salary) onlyAdmin {
         var (employee,index) = _findEmployee(employeeAddr);
         assert(employee.employeeAddress == 0x0);
         salary = salary * 1 ether;
         employees.push(Employee(employeeAddr,salary,now));
    }
    
    // 删除人员 
    function removeEmployee(address employeeAddr) onlyAdmin {
        var (employee,index) = _findEmployee(employeeAddr);
        assert(employee.employeeAddress != 0x0);
        //如若有支付的工资则先 支付， 可能会出现未支付的情况，暂不做处理 
        bool ispay = _partialPaid(employee);
         
         //删除元素并填补空白元素 
        delete(employees[index]);
        employees[index] = employees[employees.length -1];
        employees.length = employees.length -1;
    }
    
    //更新员工薪资
    function updateEmployeeSalary(address employeeAddr,uint salary) onlyAdmin {
        var (employee,index) = _findEmployee(employeeAddr);
        assert(employee.employeeAddress != 0x0);
        //如若有支付的工资则先支付 
        bool ispay = _partialPaid(employee);
        if(ispay){ //未支付则不更新最后支付时间 
            employees[index].lastPayDay = now;
        }
        employees[index].salary = salary * 1 ether;
        
    }
    
    //更新员工地址
    function updateupdateEmployeeAddr(address oldAddr,address newAddr) onlyAdmin {
        var (employee,index) = _findEmployee(oldAddr);
        assert(employee.employeeAddress != 0x0);
        employees[index].employeeAddress = newAddr;
    }
    
    
    //添加资金 
    function addFund() payable returns (uint){
        return this.balance;
    }
    
      //是否够发放当前工资 
    function hasEnoughFund() returns (bool){
        return calculateRunway() > 0;
    }
    
    //领取工资 
    function getPaid(address employeeAddr) returns (uint){
        require(msg.sender == employeeAddr);
        
        var (employee,index) = _findEmployee(employeeAddr);
        assert(employee.employeeAddress != 0x0);
        
        uint nextPayDay = employee.lastPayDay + payDuration;
        if(nextPayDay > now){
            revert();
        }
        employees[index].lastPayDay = nextPayDay;
        employeeAddr.transfer(employees[index].salary);
    }
    
   /* //计算合约balance还能支付的次数 （原始 的）
   function calculateRunway() returns (uint) {
        uint totalSalary = 0;
       for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        return this.balance / totalSalary;
    }
   */
    
     
    //计算合约balance还能支付的次数 
    /**
     *添加第一个员工后的执行结果 
     *transactionCost 22945
     *executionCost 1673 
     * */
    function calculateRunway() returns (uint r){
     //   uint sumSalary;
        for (uint i; i < employees.length; i++){
            r += employees[i].salary;
        }
        return this.balance / r;
    }
  /*  
    //不理解当使用memory数组时为何gas比使用两个 storage的局部变量要多
     function calculateRunway() view returns (uint[2] memory r){
        
        for (; r[0] < employees.length; r[0]++){
            r[1] += employees[r[0]].salary;
        }
        
        r[1] = this.balance / r[1];
        return r;
    }*/
    
    /**
     * 
     * 
     * 每添加一个员工后calculateRunway函数的gas消耗情况
     *    次数  transactionCost    executionCost           
     *    1		22966				1694          
     *    2		23747				2475 
     *    3		24528				3256 
     *    4 	25309				4037 
     *    5		26090				4818  
     *    6		26871				5599
     *    7		27652				6380 
     *    8		28433				7161
     *    9		29214				7942
     *    10	29995				8723 
     * 
     *    gas每添加一个员工后都是有变化的，因为存储在storage里面的数据在增加，每次读取storage的成本是增加的 
     *
     **/
   
}