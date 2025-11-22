# deposit_smartcontract

## Структура

- owner: Адрес владельца (msg.sender при деплое).
- Statuses: Enum для VIP или General.
- Customer: Структура с именем, балансом, статусом, временем регистрации и последним депозитом.
- customers: Маппинг адресов на Customer.

## Функции

- constructor(): Устанавливает owner.
- registration(string _name): Регистрация клиента. Только если не зарегистрирован. Статус General по умолчанию.
- deposit() payable: Депозит. Добавляет msg.value к балансу, обновляет lastDepositTime.
- customerBalance() view: Возвращает баланс клиента.
- balanceSC() view: Баланс всего контракта.
- withdrawal(uint _value, address _to): Вывод для клиента. Проверки на регистрацию, баланс, value > 0. Трансфер на _to.
- ownerWithdrawal(uint _value, address _to): Вывод для владельца. Только owner, проверка баланса контракта.
- grantVIP(address _customer): Выдача VIP. Только owner, клиент должен быть зарегистрирован и не VIP.
- accrueInterest(): Начисление процентов. 5% для General, 10% для VIP. На основе времени с lastDepositTime. Формула: (balance * rate * time) / (100 * 365 days).
- chargeServiceFee(address _customer, uint _amount): Взимание платы. Только owner, вычитает из баланса клиента (остается в контракте).
