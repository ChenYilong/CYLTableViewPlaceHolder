// Type-checked only (`tsc`): the way an app spreads CYLRefresh's props onto a ScrollView and a FlatList.
import { FlatList, ScrollView, Text } from 'react-native';
import {
  CYLPlaceholderComponent,
  CYLPlaceholderHUD,
  CYLPlaceholderStack,
  CYLRefresh,
  CYLRefreshClassicAutoFooter,
  CYLRefreshClassicHeader,
  CYLRefreshContainer,
  CYLRefreshPaging,
  CYLRefreshPagingContainer,
} from '../src/index.tsx';

const header = new CYLRefreshClassicHeader({ refreshingHandler: () => header.endRefreshing() });
const footer = new CYLRefreshClassicAutoFooter({ refreshingHandler: () => footer.endRefreshing() });

// The second floor (Android and iOS, 2026-11-24): controlled like `refreshing`; its content is the child with nativeID "cyl.refresh.secondary".
export function SecondFloorExample({ open, setOpen }: { open: boolean; setOpen: (value: boolean) => void }) {
  return (
    <CYLRefreshContainer
      refreshing={false}
      onRefresh={() => {}}
      secondaryTriggerOffset={120}
      secondaryDimension={0}
      secondaryCloseTriggerOffset={80}
      secondaryOpen={open}
      onSecondaryOpen={() => setOpen(true)}
      onSecondaryClose={() => setOpen(false)}
    >
      <FlatList data={[1, 2, 3]} keyExtractor={(n) => String(n)} renderItem={({ item }) => <Text>{item}</Text>} />
      <Text nativeID="cyl.refresh.secondary">Second floor</Text>
    </CYLRefreshContainer>
  );
}

export function ScrollViewExample() {
  return <CYLRefresh header={header}>{(props) => <ScrollView {...props}><Text>row</Text></ScrollView>}</CYLRefresh>;
}

export function FlatListExample() {
  return (
    <CYLRefresh header={header} footer={footer} refreshOnStart>
      {(props) => <FlatList {...props} data={[1, 2, 3]} keyExtractor={(n) => String(n)} renderItem={({ item }) => <Text>{item}</Text>} />}
    </CYLRefresh>
  );
}

// The native container with its footer: load more and no more data, driven by props like the header's `refreshing`.
export function NativeContainerExample({ loading, done, more }: { loading: boolean; done: boolean; more: () => void }) {
  return (
    <CYLRefreshContainer refreshing={false} onRefresh={() => {}} loadMoreEnabled loadingMore={loading} noMoreData={done} onLoadMore={more}>
      <FlatList data={[1, 2, 3]} keyExtractor={(n) => String(n)} renderItem={({ item }) => <Text>{item}</Text>} />
    </CYLRefreshContainer>
  );
}

// The footer loads again after "no more data", and the styles (the rive one with its parameters) on both platforms.
export function NativeContainerStylesExample() {
  return (
    <CYLRefreshContainer
      refreshing={false}
      onRefresh={() => {}}
      loadMoreEnabled
      loadsAfterNoMoreData
      headerStyle="rive"
      headerRive={{ riveFile: 'Bow', riveStateMachine: 'numberSimulation', rivePullInput: 'pull', riveFitsWidth: true }}
      footerStyle="rive"
      footerRive={{ riveFile: 'Bow' }}
    >
      <FlatList data={[1, 2, 3]} keyExtractor={(n) => String(n)} renderItem={({ item }) => <Text>{item}</Text>} />
    </CYLRefreshContainer>
  );
}

// A pager on the native container: the pager's header and footer show as the native ones.
const pagingHeader = new CYLRefreshClassicHeader();
const pagingFooter = new CYLRefreshClassicAutoFooter();
const pager = new CYLRefreshPaging<number>({ header: pagingHeader, footer: pagingFooter, loader: (_page, done) => done([1, 2, 3]) });

export function NativePagingExample() {
  return (
    <CYLRefreshPagingContainer paging={pager}>
      <FlatList data={pager.items ?? []} keyExtractor={(n) => String(n)} renderItem={({ item }) => <Text>{item}</Text>} />
    </CYLRefreshPagingContainer>
  );
}

// The native placeholder stack and the HUD: the component list is the configuration dictionary, actions come back by name.
export function StackExample({ token }: { token: number }) {
  return (
    <CYLPlaceholderStack
      components={[
        CYLPlaceholderComponent.icon({ style: 'cloudOff', title: 'Failed', animation: 'CYLPlaceholderLoadFailed.json', animationLoops: true }),
        CYLPlaceholderComponent.button('Retry', 'retry'),
      ]}
      restartToken={token}
      onAction={(action: string) => void action}
    />
  );
}

export function hudExample() {
  const hud = new CYLPlaceholderHUD();
  hud.showProgress(0.5, 'Uploading');
  hud.showComponents([{ type: 'button', title: 'OK', action: () => hud.dismiss() }]);
  hud.dismissWithDelay(1, () => hud.dispose());
}
