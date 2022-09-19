import { useBackend } from '../backend';
import { Button, LabeledList, Section, NumberInput, NoticeBox } from '../components';
import { NtosWindow } from '../layouts';

export const Banking = (props, context) => {
  const { act, data } = useBackend(context);
  const { locked } = data;

  return (
    <NtosWindow width={400} height={305}>
      <NtosWindow.Content>
        {locked && (
          <NoticeBox>
            Insert an ID card with active account to unlock this interface.
          </NoticeBox>
        )}

        <Section title="Interdimensional Banking Suite">
          {!locked && (
            <LabeledList>
              <LabeledList.Item label="Network Balance">
                {data.balance + ' credits'}
              </LabeledList.Item>
              <LabeledList.Item label="Withdraw">
                <NumberInput
                  value={data.withdrawal_amount}
                  minValue="0"
                  maxValue={data.balance}
                  onChange={(e, value) => {
                    act('PRG_change_withdrawal', { amount: value });
                  }}
                />
                <Button
                  content="Withdraw"
                  onClick={() => act('PRG_withdraw')}
                />
              </LabeledList.Item>

              <LabeledList.Item label="ID Balance">
                {data.id_balance + ' credits'}
              </LabeledList.Item>
              <LabeledList.Item label="Deposit">
                <NumberInput
                  value={data.deposit_amount}
                  minValue="0"
                  maxValue={data.id_balance}
                  onChange={(e, value) => {
                    act('PRG_change_deposit', { amount: value });
                  }}
                />
                <Button content="Deposit" onClick={() => act('PRG_deposit')} />
              </LabeledList.Item>

              <LabeledList.Divider />
            </LabeledList>
          )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
