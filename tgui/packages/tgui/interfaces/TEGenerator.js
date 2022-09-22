import { round } from 'common/math';
import { useBackend } from '../backend';
import { Box, Flex, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { formatSiUnit, formatPower } from '../format';

export const TEGenerator = (props, context) => {
  const { data } = useBackend(context);

  const { output, cold, hot } = data;

  return (
    <Window width={550} height={310} resizable>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Total Output">
              {formatPower(output)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {hot && cold ? (
          <Flex spacing={1}>
            <Flex.Item shrink={1} grow={1}>
              <TEGCirculator name="Cold Circulator" values={cold} />
            </Flex.Item>
            <Flex.Item shrink={1} grow={1}>
              <TEGCirculator name="Hot Circulator" values={hot} />
            </Flex.Item>
          </Flex>
        ) : (
          <Box color="bad">
            Warning! Both circulators must be connected in order to operate this
            machine.
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

const TEGCirculator = (props, context) => {
  const { name, values } = props;

  const { inletPressure, inletTemperature, outletPressure, outletTemperature } =
    values;

  return (
    <Section title={name}>
      <LabeledList>
        <LabeledList.Item label="Inlet Pressure">
          {formatSiUnit(inletPressure * 1000, 0, 'Pa')}
        </LabeledList.Item>
        <LabeledList.Item label="Inlet Temperature">
          {round(inletTemperature, 2)} K
        </LabeledList.Item>
        <LabeledList.Item label="Outlet Pressure">
          {formatSiUnit(outletPressure * 1000, 0, 'Pa')}
        </LabeledList.Item>
        <LabeledList.Item label="Outlet Temperature">
          {round(outletTemperature, 2)} K
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
