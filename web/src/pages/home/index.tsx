import React from "react";
import styled from "styled-components";
import CourtOverview from "./CourtOverview";
import LatestCases from "./LatestCases";
import Community from "./Community";
import { HomePageProvider } from "hooks/useHomePageContext";

const Container = styled.div`
  width: 100%;
  height: auto;
  background-color: ${({ theme }) => theme.lightBackground};
  padding: 32px;
`;

const Home: React.FC = () => {
  const currentTime = new Date().getTime() / 1000;
  const oneYearAgo = currentTime - 31556926; // One year in seconds
  return (
    <HomePageProvider timeframe={oneYearAgo}>
      <Container>
        <CourtOverview />
        <LatestCases />
        <Community />
      </Container>
    </HomePageProvider>
  );
};

export default Home;
