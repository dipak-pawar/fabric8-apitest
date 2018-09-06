package auth

import (
	"testing"
	"github.com/fabric8-services/fabric8-apitest/clients/auth"
	"github.com/goadesign/goa/client"
	"net/http"
	"context"
	"github.com/stretchr/testify/require"
	"encoding/json"
)

func TestAuthStatus(t *testing.T) {
	// given
	authClient := auth.New(client.HTTPClientDoer(http.DefaultClient))
	authClient.Host = "auth.openshift.io"

	ctx := context.Background()

	// when
	resp, err := authClient.ShowStatus(ctx, auth.ShowStatusPath())

	require.Nil(t, err)
	require.NotNil(t, resp)
	require.Equal(t, http.StatusOK, resp.StatusCode)
	// convert back from general response to work item list
	var status auth.Status
	err = json.NewDecoder(resp.Body).Decode(&status)
	require.Nil(t, err)
	require.Equal(t, status.ConfigurationStatus, "OK")
}
