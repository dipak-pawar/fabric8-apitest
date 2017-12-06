// +build go1.8
package main

import (
	"context"
	"encoding/json"
	"net/http"
	"testing"

	"github.com/davecgh/go-spew/spew"
	"github.com/fabric8-services/fabric8-apitest/clients/auth"
	"github.com/fabric8-services/fabric8-apitest/clients/notification"
	"github.com/fabric8-services/fabric8-apitest/clients/tenant"
	"github.com/fabric8-services/fabric8-apitest/clients/wit"
	"github.com/goadesign/goa/client"
	uuid "github.com/goadesign/goa/uuid"
	"github.com/stretchr/testify/require"
)

type filters struct {
	Query         *string
	Area          *string
	Assignee      *string
	Expression    *string
	Iteration     *string
	ParentExists  *bool
	WorkItemState *string
	WorkItemType  *uuid.UUID
}

type pagination struct {
	PageLimit  *int
	PageOffset *string
}

func TestWorkItem(t *testing.T) {

	// I intentionally left these assignments in so we know they exist
	_ = wit.Client{}
	_ = auth.Client{}
	_ = tenant.Client{}
	_ = notification.Client{}

	openshiftioSpaceID, err := uuid.FromString("020f756e-b51a-4b43-b113-45cec16b9ce9")
	require.Nil(t, err)
	//systemSpaceID, err := uuid.FromString("2e0698d8-753e-4cef-bb7c-f027634824a2")
	//require.Nil(t, err)

	ctx := context.Background()
	witClient := wit.New(client.HTTPClientDoer(http.DefaultClient))
	witClient.Host = "api.openshift.io"
	// witClient.Dump = true
	// witClient.Client.Dump = true

	// token := "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJmdWxsTmFtZSI6IlRlc3QgRGV2ZWxvcGVyIiwiaW1hZ2VVUkwiOiIiLCJ1dWlkIjoiNGI4Zjk0YjUtYWQ4OS00NzI1LWI1ZTUtNDFkNmJiNzdkZjFiIn0.ML2N_P2qm-CMBliUA1Mqzn0KKAvb9oVMbyynVkcyQq3myumGeCMUI2jy56KPuwIHySv7i-aCUl4cfIjG-8NCuS4EbFSp3ja0zpsv1UDyW6tr-T7jgAGk-9ALWxcUUEhLYSnxJoEwZPQUFNTWLYGWJiIOgM86__OBQV6qhuVwjuMlikYaHIKPnetCXqLTMe05YGrbxp7xgnWMlk9tfaxgxAJF5W6WmOlGaRg01zgvoxkRV-2C6blimddiaOlK0VIsbOiLQ04t9QA8bm9raLWX4xOkXN4ubpdsobEzcJaTD7XW0pOeWPWZY2cXCQulcAxfIy6UmCXA14C07gyuRs86Rw"
	// witClient.SetJWTSigner(&client.APIKeySigner{
	// 	SignQuery: false,
	// 	KeyName:   "Authorization",
	// 	KeyValue:  token,
	// 	Format:    "Bearer %s",
	// })

	t.Run("as a logged out user", func(t *testing.T) {
		t.Run("list", func(t *testing.T) {
			t.Run("state=open", func(t *testing.T) {
				t.Run("ok", func(t *testing.T) {
					// given
					path := wit.ListWorkitemsPath(openshiftioSpaceID)
					expextedState := "open"
					f := filters{
						WorkItemState: &expextedState,
					}
					p := pagination{}
					var ifModifiedSince *string
					var ifNoneMatch *string

					// when
					resp, err := witClient.ListWorkitems(ctx, path, f.Query, f.Area, f.Assignee, f.Expression, f.Iteration, f.ParentExists, f.WorkItemState, f.WorkItemType, p.PageLimit, p.PageOffset, ifModifiedSince, ifNoneMatch)

					// then
					require.Nil(t, err)
					require.NotNil(t, resp)
					require.Equal(t, http.StatusOK, resp.StatusCode)
					// convert back from general response to work item list
					var wiList wit.WorkItemList
					err = json.NewDecoder(resp.Body).Decode(&wiList)
					require.Nil(t, err)
					// double check that all returned work items are indeed open
					for idx, wi := range wiList.Data {
						actualState, ok := wi.Attributes["system.state"]
						require.True(t, ok, "failed to find 'system.state' attribute in work item #%d %s", idx, spew.Sdump(wi))
						require.Equal(t, expextedState, actualState)
						t.Log("found open work item with title: %s", wi.Attributes["system.title"])
					}
				})
			})
		})
	})

}
