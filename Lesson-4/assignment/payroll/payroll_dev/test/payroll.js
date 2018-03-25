var PayRoll = artifacts.require("./PayRoll.sol");

contract('PayRoll', function(accounts) {
    
  it("add  account3 to employees.", function() {
    return PayRoll.deployed().then(function(instance){
        pr = instance;
        pr.addEmployee(accounts[3],1,{from:accounts[0]});
    }).then(function(){
        return pr.employees.call(accounts[3]);
    }).then(function(employee){
        assert.equal(employee[0],accounts[3],"success to add employee 1.");
    });
  });


  it("add account2 and remove account2 successfully", function () {
    return PayRoll.deployed().then(function (instance) {
        pr = instance;
        return pr.addEmployee(accounts[2], 1,{from:accounts[0]});
    }).then(function () {
        return pr.employees.call(accounts[2]);
    }).then(function (employee) {
        add_employee = employee[0];
     }).then(function () {
          pr.removeEmployee(accounts[2],{from:accounts[0]});
     }).then(function () {
         return pr.employees.call(accounts[2]);
     }).then(function (employee) {
         rm_employee = employee[0];
    }).then(function () {
        assert.equal(add_employee, accounts[2], "add account2 ok");
        assert.equal(rm_employee, 0, "remove account2 ok");
    });
});





it("test getPaid successfully", function () {
    return PayRoll.deployed().then(function (instance) {
        pr = instance;
        amount = web3.toWei(10, "ether")
        pr.addFund({ from: accounts[0], value: amount });
    }).then(function () {
        pr.addEmployee(accounts[1], 1,{from: accounts[0]});
    }).then(function () {
        return pr.employees.call(accounts[1]);
    }).then(function (employee) {
        e_addr = employee[0];
        e_balance_old = web3.eth.getBalance(e_addr);
    }).then(function () {
        return new Promise(resolve => setTimeout(resolve, 10 * 1000));
     }).then(function () {
        pr.getPaid(accounts[1],{from: accounts[1]});
     }).then(function () {
        return pr.employees.call(accounts[1]);
    }).then(function (e) {
        e_balance_new = web3.eth.getBalance(e[0]);
    }).then(function () {
        assert.ok(e_balance_new.gt(e_balance_old), "add balance successfully");
    });
});


});
