import { useState } from "react";

export function CommitScreen({
  errorMessage,
  keepAliveCallback,
  loading,
  lastCommit,
  contract,
}: {
  errorMessage: string;
  keepAliveCallback: () => void;
  loading: boolean;
  lastCommit: Date | undefined;
  contract: string;
}) {
  const now = new Date();
  const hoursString = (() => {
    if (lastCommit === undefined) {
      return "loading...";
    } else {
      const hours = Math.floor(
        Math.abs((now.getTime() - lastCommit.getTime()) / 36e5)
      );
      return `${hours.toString()} hours`;
    }
  })();

  return (
    <div className="container">
      <div>
        <span>Commiting to contract:</span>
        <br />
        <small>{contract}</small>
      </div>
      <p>
        Time since last commit:
        <br />
        {hoursString}
      </p>
      <button
        className={`btn btn-primary ${loading ? "loading" : ""}`}
        style={{ width: "125px", height: "50px" }}
        onClick={keepAliveCallback}
      >
        Keep Alive
      </button>
      {errorMessage ? (
        <div className="toast toast-error">
          <h6>Error:</h6>
          <p>{errorMessage}</p>
        </div>
      ) : (
        <></>
      )}
    </div>
  );
}
